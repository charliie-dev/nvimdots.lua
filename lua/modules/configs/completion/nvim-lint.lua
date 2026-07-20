return function()
	local lint = require("lint")

	-- Local customizations of upstream linter modules, as functions so they can
	-- be re-applied when refresh_linter below rebuilds a module after an install.
	local overrides = {
		-- selene: stdin mode uses process CWD to find selene.toml, which may not be the
		-- nvim config dir. Pass --config explicitly so vim.yml is always found.
		selene = function(linter)
			linter.args = {
				"--display-style",
				"json",
				"--config",
				vim.fn.stdpath("config") .. "/selene.toml",
				"-",
			}
		end,
		-- markdownlint-cli2: stdin broken under bun's node shim (for-await yields empty).
		-- Override to file-based mode and update parser for "path:line:col severity message" format.
		["markdownlint-cli2"] = function(linter)
			linter.stdin = false
			linter.args = {
				"--config",
				vim.fn.stdpath("config") .. "/.markdownlint.yml",
			}
			linter.stream = "stderr"
			linter.parser = require("lint.parser").from_pattern(
				"[^:]+:(%d+):(%d+) (%a+) (.+)",
				{ "lnum", "col", "severity", "message" },
				{ ["error"] = vim.diagnostic.severity.ERROR, ["warning"] = vim.diagnostic.severity.WARN },
				{ source = "markdownlint" }
			)
		end,
	}
	---@param name string
	local function apply_override(name)
		local apply = overrides[name]
		if not apply then
			return
		end
		local linter = lint.linters[name]
		if type(linter) == "table" then
			apply(linter)
		end
	end
	for name in pairs(overrides) do
		apply_override(name)
	end

	-- shuck: lints shell embedded in GitHub Actions `run:` blocks (actionlint
	-- skips those); standalone sh/bash comes from the shuck LSP server. No usable
	-- stdin mode (needs a project root), so run file-based and parse JSON.
	lint.linters.shuck = {
		name = "shuck",
		cmd = "shuck",
		stdin = false,
		append_fname = true,
		args = { "check", "--output-format", "json" },
		stream = "stdout",
		ignore_exitcode = true, -- exit code 1 means violations were found
		parser = function(output, _)
			local diagnostics = {}
			if output == nil or output == "" then
				return diagnostics
			end
			local ok, decoded = pcall(vim.json.decode, output)
			if not ok or type(decoded) ~= "table" then
				return diagnostics
			end
			local severities = {
				error = vim.diagnostic.severity.ERROR,
				warning = vim.diagnostic.severity.WARN,
				info = vim.diagnostic.severity.INFO,
				hint = vim.diagnostic.severity.HINT,
			}
			for _, item in ipairs(decoded) do
				local loc = item.location or {}
				local endloc = item.end_location or {}
				table.insert(diagnostics, {
					lnum = (loc.row or 1) - 1,
					col = (loc.column or 1) - 1,
					end_lnum = (endloc.row or loc.row or 1) - 1,
					end_col = (endloc.column or loc.column or 1) - 1,
					severity = severities[item.severity] or vim.diagnostic.severity.WARN,
					code = item.code,
					message = item.message,
					source = "shuck",
				})
			end
			return diagnostics
		end,
	}

	local by_ft = {
		dockerfile = { "hadolint" },
		go = { "golangcilint" },
		lua = { "selene" },
		markdown = { "markdownlint-cli2" },
		javascript = { "oxlint" },
		javascriptreact = { "oxlint" },
		nix = { "deadnix", "statix" },
		sh = { "shellcheck" },
		typescript = { "oxlint" },
		typescriptreact = { "oxlint" },
		systemd = { "systemdlint" },
		["yaml.github"] = { "actionlint", "shuck" },
		zsh = { "zsh" },
	}
	lint.linters_by_ft = by_ft

	-- Filetype -> linter names via nvim-lint's own (private) resolution while it
	-- survives, so the two can't drift; else the exact by_ft entry — every
	-- compound filetype this config lints is an explicit key.
	local function linters_for_ft(ft)
		local ok, names = pcall(lint._resolve_linter_by_ft, ft)
		if ok and type(names) == "table" then
			return names
		end
		return by_ft[ft] or {}
	end

	-- Resolve `linter_deps` discovery-first against nvim-lint's own registry,
	-- batched BY FILETYPE off the lint events below: the probe requires the
	-- linter module, and some (golangcilint) run blocking system calls at load.
	local tools = require("modules.utils.tools")
	-- No factory-wrapper machinery here on purpose: both overridden linters
	-- (selene, markdownlint-cli2) are plain-table modules upstream, so a
	-- per-call wrapper would be unreachable speculation. If upstream ever
	-- converts one to a factory, the override silently stops applying (the
	-- probe's factory branch still resolves the linter) — revisit then.
	---Rebuild a module-backed linter for a late configure: some (golangcilint)
	---compute `args` by RUNNING their binary at module-load time, and a result
	---computed while the binary was absent would persist all session.
	---Deliberately SYNCHRONOUS inside the resolver's configure (F24 evaluated
	---and rejected deferral): the hand-off pending gate and the aggregated
	---warning both key off configure's synchronous success/failure — deferring
	---the reload would report success before the rebuild happened.
	---@param name string
	local function refresh_linter(name)
		local module = "lint.linters." .. name
		if not tools.module_path(module) then
			return -- defined inline (e.g. shuck), not module-backed: nothing to reload
		end
		local prev = lint.linters[name]
		package.loaded[module] = nil
		-- Also drop any explicit assignment (a wrapped factory) shadowing the
		-- lint.linters __index loader.
		rawset(lint.linters, name, nil)
		-- Require it OURSELVES: the __index loader pcall-swallows a reload
		-- failure into nil, which would read as configure success and clear
		-- the hand-off pending gate over a stale linter.
		local ok, err = pcall(require, module)
		if not ok then
			-- Restore — stale args beat a deleted linter (asserts on try_lint) —
			-- then raise so the resolver keeps the name pending and reported.
			rawset(lint.linters, name, prev)
			tools.raise_verbatim("linter reload failed after install: " .. tostring(err))
		end
		apply_override(name)
	end
	---Resolve one batch of linter names. Synchronous configures land before the
	---lint that triggered the batch; late configures (install completion /
	---post-refresh) have no later lint event and re-lint buffers themselves.
	---@param names string[]
	local function resolve_batch(names)
		tools.resolve_runtime_tools("nvim-lint", names, function(name)
			-- Read — and possibly lazy-load — the linter (the __index loader
			-- requires the module; Mason's bin dir is already on $PATH).
			local linter = lint.linters[name]
			if linter == nil then
				-- The metatable swallows loader errors: a module that exists but
				-- throws is a broken config, not a typo. Re-require re-throws.
				local module = "lint.linters." .. name
				if not tools.module_path(module) then
					return nil -- unknown linter name (typo / not registered)
				end
				-- The swallowed require left the loader sentinel behind: retrying
				-- as-is only yields "loop or previous error loading module".
				-- Clear it so the retry re-throws the ORIGINAL error (the module
				-- never finished loading, so no side effects run twice).
				package.loaded[module] = nil
				local ok, err = pcall(require, module)
				if not ok then
					return { broken = tostring(err) }
				end
				-- The retry loaded (nondeterministic loader): pick up the fresh value.
				linter = lint.linters[name]
				if linter == nil then
					return nil
				end
			end
			if type(linter) == "function" then
				-- A throwing factory is a broken config, not an unknown name.
				local ok, resolved = pcall(linter)
				if not ok then
					return { broken = tostring(resolved) }
				end
				linter = resolved
			end
			if type(linter) ~= "table" then
				return nil
			end
			local cmd = linter.cmd
			if type(cmd) == "function" then
				local ok, resolved = pcall(cmd)
				if not ok then
					return { broken = tostring(resolved) }
				end
				cmd = resolved
			end
			-- A non-string cmd means the linter resolves its command at runtime.
			return { binary = type(cmd) == "string" and cmd or nil }
		end, function(name, late)
			if late then
				-- Rebuild so load-time work sees the just-installed binary
				-- (refresh_linter re-applies the local override itself).
				refresh_linter(name)
			else
				apply_override(name)
			end
			if late then
				-- No lint event follows a late configure: re-lint every loaded
				-- buffer whose filetype maps to this linter.
				vim.schedule(function()
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if
							vim.api.nvim_buf_is_loaded(buf)
							and vim.tbl_contains(linters_for_ft(vim.bo[buf].filetype), name)
						then
							vim.api.nvim_buf_call(buf, function()
								pcall(function()
									lint.try_lint(nil, { ignore_errors = true })
								end)
							end)
						end
					end
				end)
			end
		end)
	end

	-- Names mapped in `by_ft` resolve lazily on their filetype's first lint
	-- event; the rest (typos, manual-only linters) get a deferred immediate pass.
	local raw_deps = require("core.settings").linter_deps
	local deps = tools.normalize_names(raw_deps)
	local mapped = {}
	for _, names in pairs(by_ft) do
		for _, name in ipairs(names) do
			mapped[name] = true
		end
	end
	local pending, immediate = {}, {}
	for _, name in ipairs(deps) do
		if mapped[name] then
			pending[name] = true
		else
			immediate[#immediate + 1] = name
		end
	end
	-- Entries normalize_names drops (non-string / empty) are config mistakes:
	-- forward them raw so the resolver's own sweep reports them in the unknown
	-- bucket, identically to the other consumers.
	if type(raw_deps) == "table" then
		for i = 1, table.maxn(raw_deps) do
			local entry = raw_deps[i]
			if entry ~= nil and (type(entry) ~= "string" or entry == "") then
				immediate[#immediate + 1] = entry
			end
		end
	end
	if #immediate > 0 then
		vim.schedule(function()
			resolve_batch(immediate)
		end)
	end

	local ft_done = {}
	local function ensure_resolved(ft)
		if ft == "" or ft_done[ft] then
			return
		end
		ft_done[ft] = true
		local batch = {}
		for _, name in ipairs(linters_for_ft(ft)) do
			if pending[name] then
				pending[name] = nil
				batch[#batch + 1] = name
			end
		end
		if #batch > 0 then
			resolve_batch(batch)
		end
	end

	-- FileType is resolve-only, no lint: it covers the buffer whose BufReadPost
	-- loaded this plugin — lazy.nvim replays that event before filetype
	-- detection, so the lint callback sees an empty filetype there.
	vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "FileType" }, {
		group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
		callback = function(args)
			-- Resolve this filetype's deps before the lint they gate, so the first
			-- lint already spawns by absolute path when Mason's bin dir is off $PATH.
			ensure_resolved(vim.bo[args.buf].filetype)
			if args.event ~= "FileType" then
				lint.try_lint(nil, { ignore_errors = true })
			end
		end,
	})
end
