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
		-- markdownlint-cli2: only add the global config — it discovers configs
		-- upward from the linted file, so projects without their own would
		-- otherwise fall back to factory defaults. stdin mode and the parser
		-- stay upstream's; its errorformat fallback ("stdin:%l %m") keeps
		-- findings whose column is unknown (e.g. MD012).
		["markdownlint-cli2"] = function(linter)
			linter.args = {
				"--config",
				vim.fn.stdpath("config") .. "/.markdownlint.yml",
				"-",
			}
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

	-- shuck: lints shell embedded in GitHub Actions `run:` blocks with rules
	-- beyond actionlint's shellcheck pass-through; standalone sh/bash comes
	-- from the shuck LSP server. No usable stdin mode (needs a project root),
	-- so run file-based and parse JSON.
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
	-- linter module, and some block at load (see refresh_linter below).
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
		-- Also drop any explicit assignment (e.g. a prior error-path restore
		-- below) shadowing the lint.linters __index loader.
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
	-- First broken-load verdict per linter module: the recovery re-require
	-- below re-runs any side effects the module executed before its failure
	-- point (golangcilint spawns its binary at load time — see refresh_linter),
	-- so it must run at most once per session, not once per resolve batch.
	-- Session staleness is fine: fixing a broken module needs a restart anyway.
	local broken_probe = {}
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
				if broken_probe[module] then
					return { broken = broken_probe[module] }
				end
				-- The swallowed require left the loader sentinel behind: retrying
				-- as-is only yields "loop or previous error loading module".
				-- Clear it so the retry re-throws the ORIGINAL error. COST,
				-- accepted and bounded by the memo above: side effects the module
				-- ran before failing (load-time spawns) run a second time here.
				package.loaded[module] = nil
				local ok, err = pcall(require, module)
				if not ok then
					broken_probe[module] = tostring(err)
					return { broken = broken_probe[module] }
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
				-- buffer whose filetype maps to this linter — running only THIS
				-- linter (try_lint(nil) would respawn the buffer's whole set).
				-- Siblings that haven't linted yet (the plugin-loading buffer's
				-- FileType is resolve-only) catch up on their next natural lint
				-- event; a late configure is not that event.
				vim.schedule(function()
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if
							vim.api.nvim_buf_is_loaded(buf)
							and vim.tbl_contains(linters_for_ft(vim.bo[buf].filetype), name)
						then
							vim.api.nvim_buf_call(buf, function()
								pcall(function()
									lint.try_lint(name, { ignore_errors = true })
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
	local deps, invalid_deps = tools.split_dep_names(raw_deps)
	-- Superseded sessions from a previous run of this consumer must not be retried (re-source guard).
	tools.drop_sessions("nvim-lint")
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
	-- Entries split_dep_names drops (non-string / empty) are config mistakes:
	-- forward them raw so the resolver's own sweep reports them in the unknown
	-- bucket, identically to the other consumers.
	vim.list_extend(immediate, invalid_deps)
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

	-- Parity backstop, mirroring mason-lspconfig's sweep intent: a mapped
	-- linter whose filetype never fires a lint event this session must still
	-- be resolved (installed or reported) instead of silently skipped.
	--
	-- Shape, driven by two constraints:
	--  * The probe requires linter modules and golangcilint blocks at load
	--    (deliberate, see refresh_linter above), so the sweep must not land
	--    mid-editing: the 120s timer only ARMS a one-shot CursorHold(I) idle
	--    gate, and the gate warms module loads one per tick before a single
	--    aggregated resolve.
	--  * A config re-source strands this closure with a stale `pending`
	--    table: every async hop re-checks a vim.g generation token (survives
	--    both re-source flavors), and the gate autocmd dies with the
	--    augroup's clear=true above.
	local SWEEP_DELAY_MS = tools.SWEEP_DELAY_MS -- one source; divergence rationale lives there
	local SWEEP_FALLBACK_MS = 60000 -- idle-gate fallback: bounds the sweep when idle predates the gate
	local gen = (vim.g._nvimlint_sweep_gen or 0) + 1
	vim.g._nvimlint_sweep_gen = gen
	local function sweep_live()
		return vim.g._nvimlint_sweep_gen == gen
	end

	local function run_sweep()
		-- Snapshot WITHOUT draining: `pending` stays owned by ensure_resolved
		-- until the moment of resolution, so a filetype opened mid-warm still
		-- takes its normal first-event path (resolve before its first lint).
		local names = vim.tbl_keys(pending)
		if #names == 0 then
			return
		end
		table.sort(names) -- pairs order is nondeterministic; keep the warning stable
		-- The event path loads linter modules inside tools.resolve(), AFTER it
		-- put Mason's bin dir on $PATH. PATH-sensitive module loads (see
		-- refresh_linter above) must see the same environment when the warm
		-- phase loads them first instead.
		tools.ensure_mason_on_path()
		-- Warm the __index module loads one per tick (bounds any blocking
		-- load to a single tick), then resolve everything still pending in
		-- ONE batch so the missing-tools warning stays aggregated. Loader
		-- errors are swallowed here on purpose: resolve_batch's probe
		-- re-derives broken-vs-unknown.
		local index = 0
		local function step()
			if not sweep_live() then
				return
			end
			index = index + 1
			if index <= #names then
				local name = names[index]
				if pending[name] then -- skip names an event already claimed
					pcall(function()
						local _ = lint.linters[name]
					end)
				end
				vim.schedule(step)
				return
			end
			local batch = {}
			for _, name in ipairs(names) do
				if pending[name] then
					pending[name] = nil
					batch[#batch + 1] = name
				end
			end
			if #batch > 0 then
				resolve_batch(batch) -- order-preserving subset of sorted `names`
			end
		end
		step()
	end

	vim.defer_fn(function()
		if not sweep_live() or next(pending) == nil then
			return
		end
		-- Arm, don't run: CursorHold(I) keeps the module loads off keystroke
		-- bursts in the interactive case. But an autocmd created MID-idle never
		-- fires — nvim's did_cursorhold flag was already consumed by whichever
		-- CursorHold consumer registered at startup and only a real key press
		-- resets it — so a session left idle before this arms would defer the
		-- sweep unboundedly. The fallback timer bounds that: first trigger
		-- wins; run_sweep's warm loop bounds per-tick blocking either way.
		local fired = false
		local gate = nil
		local function fire()
			if fired or not sweep_live() then
				return
			end
			fired = true
			if gate then
				pcall(vim.api.nvim_del_autocmd, gate)
			end
			run_sweep()
		end
		-- One-shot across BOTH events via del_autocmd — a callback returning
		-- true only drops the registration of the event that fired.
		gate = vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			group = "NvimLint",
			callback = fire,
		})
		vim.defer_fn(fire, SWEEP_FALLBACK_MS)
	end, SWEEP_DELAY_MS)

	-- The buffer that loaded this plugin (lazy triggers: BufReadPost / BufWritePost)
	-- can slip through the initial lint in ONE case: a BufReadPost load, where
	-- lazy.nvim replays BufReadPost BEFORE ftdetect (ft="", a no-op lint) and the
	-- FileType handler above is resolve-only — so this buffer alone would wait for
	-- the next InsertLeave/save. When ft is ALREADY set at config time (a
	-- BufWritePost load, or any ft-set load), the replayed trigger event lints via
	-- the main handler, so NO help is needed — registering a one-shot there would
	-- double-lint (the round-1 O1 defect). Hence: only the ft="" case, and only
	-- once, in the NvimLint group so a config re-source's clear=true wipes a stale
	-- copy instead of stacking.
	local load_buf = vim.api.nvim_get_current_buf()
	if vim.bo[load_buf].filetype == "" then
		vim.api.nvim_create_autocmd("FileType", {
			group = "NvimLint",
			buffer = load_buf,
			once = true,
			callback = function()
				ensure_resolved(vim.bo[load_buf].filetype)
				vim.api.nvim_buf_call(load_buf, function()
					lint.try_lint(nil, { ignore_errors = true })
				end)
			end,
		})
	end
end
