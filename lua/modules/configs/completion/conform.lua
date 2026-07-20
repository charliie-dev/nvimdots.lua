return function()
	local settings = require("core.settings")
	local disabled_workspaces = settings.format_disabled_dirs
	local format_on_save_enabled = settings.format_on_save
	local format_notify = settings.format_notify
	local format_modifications_only = settings.format_modifications_only
	local format_timeout = settings.format_timeout
	local block_list = settings.formatter_block_list

	-- Load clang_format extra_args from user or default config
	local function clang_format_args()
		local ok, args = pcall(require, "user.configs.formatters.clang_format")
		if not ok then
			-- Distinguish "not found" from "has errors"
			if type(args) == "string" and not args:find("module .* not found") then
				vim.notify("[Conform] Error loading user clang_format config: " .. args, vim.log.levels.ERROR)
			end
			args = require("completion.formatters.clang_format")
		end
		return args
	end

	---Check if the current file is in a disabled workspace
	---@param bufnr integer
	---@return boolean
	local function is_disabled_workspace(bufnr)
		local filedir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":h")
		for _, dir in ipairs(disabled_workspaces) do
			if vim.regex(vim.fs.normalize(dir)):match_str(filedir) ~= nil then
				if format_notify then
					vim.notify(
						string.format("[Conform] Formatting disabled for files under [%s].", vim.fs.normalize(dir)),
						vim.log.levels.WARN,
						{ title = "Conform" }
					)
				end
				return true
			end
		end
		return false
	end

	---The gates a buffer must pass before an automatic format, grouped into one
	---named predicate for the format_on_save callback's readability.
	---@param bufnr integer
	---@return boolean
	local function autoformat_allowed(bufnr)
		return format_on_save_enabled
			and block_list[vim.bo[bufnr].filetype] ~= true
			and not is_disabled_workspace(bufnr)
			and not vim.g.disable_autoformat
			and not vim.b[bufnr].disable_autoformat
	end

	---Format only git-modified lines using gitsigns hunks + conform range format
	---@param bufnr integer
	---@return boolean @true if modifications were formatted
	local function format_modifications(bufnr)
		local ok, gitsigns = pcall(require, "gitsigns")
		if not ok then
			vim.notify("[Conform] gitsigns unavailable, falling back to full-buffer format", vim.log.levels.WARN)
			return false
		end

		local hunks = gitsigns.get_hunks(bufnr)
		if not hunks or #hunks == 0 then
			return false
		end

		-- Format hunks in reverse to avoid line offset issues
		local has_error = false
		for i = #hunks, 1, -1 do
			local hunk = hunks[i]
			if hunk.added and hunk.added.count > 0 then
				local start_line = hunk.added.start
				local end_line = start_line + hunk.added.count - 1
				local ok_fmt, err = pcall(require("conform").format, {
					bufnr = bufnr,
					range = {
						start = { start_line, 0 },
						["end"] = { end_line, math.huge },
					},
					quiet = true,
				})
				if not ok_fmt then
					has_error = true
					vim.notify(
						string.format("[Conform] Failed to format hunk at line %d: %s", start_line, err),
						vim.log.levels.WARN,
						{ title = "Conform" }
					)
				end
			end
		end

		if format_notify and not has_error then
			vim.notify("[Conform] Formatted changed lines successfully!", vim.log.levels.INFO, { title = "Conform" })
		end
		return true
	end

	local tools = require("modules.utils.tools")

	require("modules.utils").load_plugin("conform", {
		default_format_opts = {
			timeout_ms = format_timeout,
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			c = { "clang-format" },
			cmake = { "cmake_format" },
			cpp = { "clang-format" },
			cs = { "clang-format" },
			css = { "prettier" },
			go = { "goimports", "gofumpt" },
			cuda = { "clang-format" },
			graphql = { "prettier" },
			html = { "superhtml" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			json = { "fixjson", "prettier" },
			jsonc = {}, -- fixjson/prettier strip comments; fallback to LSP (jsonls) for JSONC formatting
			lua = { "stylua" },
			markdown = { "mdsf" },
			nix = { "nixfmt", "statix" },
			objc = { "clang-format" },
			objcpp = { "clang-format" },
			proto = { "clang-format" },
			sh = { "shellharden" },
			angular = { "prettier" },
			handlebars = { "prettier" },
			less = { "prettier" },
			scss = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			vue = { "prettier" },
			yaml = { "prettier" },
			zsh = { "beautysh" },
		},
		formatters = {
			["clang-format"] = {
				prepend_args = clang_format_args(),
			},
			statix = {
				command = "statix",
				args = { "fix", "--stdin" },
				stdin = true,
			},
			-- prettier: stdin is broken under bun's node shim, so use --write on
			-- conform's temp copy (`stdin = false` points $FILENAME at a
			-- `.conform.$RANDOM.*` copy; the real file is never touched).
			prettier = {
				command = "prettier",
				args = { "--write", "$FILENAME" },
				stdin = false,
			},
		},
		format_on_save = format_on_save_enabled and function(bufnr)
			-- Disabled filetypes, disabled workspaces, and the global/buffer toggles
			if not autoformat_allowed(bufnr) then
				return
			end

			-- Format only modified lines if enabled
			if format_modifications_only then
				if format_modifications(bufnr) then
					return
				end
				-- Fall through to full format if no hunks found
			end

			return {}
		end or false,
	})

	-- Make Mason's bin dir resolvable BEFORE the replayed save formats — a bare
	-- Mason formatter binary must spawn — so no per-formatter command rewrite is
	-- needed. Idempotent; the resolver calls it again itself.
	tools.ensure_mason_on_path()
	-- Resolve `formatter_deps` (conform formatter names) discovery-first against
	-- conform's own registry, so a missing formatter is installed / reported.
	-- The probe only drives install/warn — nothing on the save path reads it —
	-- so the whole resolve moves off the BufWritePre tick that lazy-loaded
	-- conform instead of delaying the first save behind it.
	vim.schedule(function()
		tools.resolve_runtime_tools("conform.nvim", settings.formatter_deps, function(name)
			-- get_formatter_config is conform's @private API; if dropped, degrade to
			-- "resolves itself" rather than misreporting every formatter as unknown.
			local conform = require("conform")
			if type(conform.get_formatter_config) ~= "function" then
				return { binary = nil }
			end
			-- get_formatter_config runs a function-form override directly, so pcall keeps a
			-- throwing override (a broken config) from being misread as an unknown name.
			local ok, config, err = pcall(conform.get_formatter_config, name)
			if not ok then
				return { broken = tostring(config) }
			end
			if config then
				-- A function-form command resolves per buffer at format time (e.g. the
				-- builtin from_node_modules): treat it as self-resolving rather than
				-- evaluating it for a representative binary — a node_modules command
				-- shouldn't map to a Mason install anyway.
				if type(config.command) == "function" then
					return { binary = nil }
				end
				return { binary = config.command }
			end
			-- (nil, err) is a real formatter with a broken config; bare nil is an unknown name.
			if type(err) == "string" then
				return { broken = err }
			end
			-- A function-form override may legitimately return nil for the
			-- probe-time buffer (this probe runs on a scheduled tick against
			-- whatever buffer happens to be current): its existence proves the
			-- name real, but nothing is verifiable — report it unresolved
			-- (missing bucket, tailored reason) instead of a typo or a silent pass.
			local overrides = conform.formatters
			if type(overrides) == "table" and type(overrides[name]) == "function" then
				return { unresolved = true }
			end
			return nil
		end)
	end)

	-- User commands
	vim.api.nvim_create_user_command("Format", function(args)
		local range = nil
		if args.count ~= -1 then
			local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
			range = {
				start = { args.line1, 0 },
				["end"] = { args.line2, end_line:len() },
			}
		end
		require("conform").format({
			async = true,
			range = range,
		}, function(err)
			if not err and format_notify then
				vim.notify("[Conform] Format successfully!", vim.log.levels.INFO, { title = "Conform" })
			elseif err then
				vim.notify(
					string.format("[Conform] Format error: %s", err),
					vim.log.levels.ERROR,
					{ title = "Conform" }
				)
			end
		end)
	end, { range = true })

	vim.api.nvim_create_user_command("FormatToggle", function()
		if vim.g.disable_autoformat then
			vim.g.disable_autoformat = false
			vim.notify("Format-on-save enabled", vim.log.levels.INFO, { title = "Conform" })
		else
			vim.g.disable_autoformat = true
			vim.notify("Format-on-save disabled", vim.log.levels.WARN, { title = "Conform" })
		end
	end, {})

	vim.api.nvim_create_user_command("FormatterToggleFt", function(opts)
		if block_list[opts.args] == nil then
			vim.notify(
				string.format("[Conform] Formatter for [%s] recorded and disabled.", opts.args),
				vim.log.levels.WARN,
				{ title = "Conform" }
			)
			block_list[opts.args] = true
		else
			block_list[opts.args] = not block_list[opts.args]
			vim.notify(
				string.format(
					"[Conform] Formatter for [%s] %s.",
					opts.args,
					not block_list[opts.args] and "enabled" or "disabled"
				),
				not block_list[opts.args] and vim.log.levels.INFO or vim.log.levels.WARN,
				{ title = "Conform" }
			)
		end
	end, { nargs = 1, complete = "filetype" })

	-- Auto stop shell LSPs for .env files (migrated from null-ls config).
	-- Both bashls and shuck attach to .env's `sh` filetype and only add noise there.
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(event)
			local bufname = vim.api.nvim_buf_get_name(event.buf)
			if bufname:match("%.env$") or bufname:match("%.env%.") then
				vim.cmd.LspStop("bashls")
				vim.cmd.LspStop("shuck")
			end
		end,
	})
end
