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
					timeout_ms = format_timeout,
					lsp_format = "fallback",
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

	require("modules.utils").load_plugin("conform", {
		formatters_by_ft = {
			c = { "clang-format" },
			cmake = { "cmake_format" },
			cpp = { "clang-format" },
			cs = { "clang-format" },
			css = { "prettierd" },
			cuda = { "clang-format" },
			graphql = { "prettierd" },
			html = { "prettierd" },
			javascript = { "prettierd" },
			javascriptreact = { "prettierd" },
			json = { "fixjson", "prettierd" },
			jsonc = { "fixjson", "prettierd" },
			less = { "prettierd" },
			lua = { "stylua" },
			markdown = { "mdsf", "prettierd" },
			nix = { "nixfmt", "statix" },
			objc = { "clang-format" },
			objcpp = { "clang-format" },
			proto = { "clang-format" },
			scss = { "prettierd" },
			sh = { "shellharden" },
			typescript = { "prettierd" },
			typescriptreact = { "prettierd" },
			vue = { "prettierd" },
			yaml = { "prettierd" },
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
		},
		format_on_save = format_on_save_enabled and function(bufnr)
			-- Check disabled filetypes
			if block_list[vim.bo[bufnr].filetype] == true then
				return
			end

			-- Check disabled workspaces
			if is_disabled_workspace(bufnr) then
				return
			end

			-- Check global toggle
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end

			-- Format only modified lines if enabled
			if format_modifications_only then
				if format_modifications(bufnr) then
					return
				end
				-- Fall through to full format if no hunks found
			end

			return {
				timeout_ms = format_timeout,
				lsp_format = "fallback",
			}
		end or false,
	})

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
			lsp_format = "fallback",
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

	-- Auto stop bashls for .env files (migrated from null-ls config)
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(event)
			local bufname = vim.api.nvim_buf_get_name(event.buf)
			if bufname:match("%.env$") or bufname:match("%.env%.") then
				vim.cmd.LspStop("bashls")
			end
		end,
	})
end
