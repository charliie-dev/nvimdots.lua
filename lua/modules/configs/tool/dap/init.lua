return function()
	local dap = require("dap")
	local dapui = require("dapui")

	local icons = { dap = require("modules.utils.icons").get("dap") }
	local colors = require("modules.utils").get_palette()
	local mappings = require("tool.dap.dap-keymap")
	local tools = require("modules.utils.tools")

	---Ordered client-config modules for an adapter: user override, then repo preset.
	---@param name string
	---@return string[]
	local function client_modules(name)
		return { "user.configs.dap-clients." .. name, "tool.dap.clients." .. name }
	end

	local client_config_cache = {}
	---Load the first usable client config (user override, then repo preset),
	---memoized per adapter: the resolver consults it from several predicates
	---(has_local_config, unknown_of) plus the handler, and an uncached miss
	---would re-run a failed require each time. First success wins outright (no
	---merge-base semantics); a higher-precedence exists-but-broken candidate's
	---reason survives alongside a lower-precedence success, so the handler can
	---refuse to fall past a broken override (usable_or_raise raises it).
	---@param name string
	---@return any value, string|nil broken_reason, boolean any_exists, boolean user_won
	local function load_client_config(name)
		local cached = client_config_cache[name]
		if not cached then
			cached = { value = nil, broken_reason = nil, any_exists = false, user_won = false }
			local modules = client_modules(name)
			for index, module in ipairs(modules) do
				local ok, value, exists, reason = tools.load_module_or_report(module, "nvim-dap")
				if ok then
					cached.value = value
					-- Recorded here, where `modules` is already built — the
					-- handler must not rebuild the list per call just to ask
					-- whether the user candidate won.
					cached.user_won = index == 1
					cached.any_exists = true
					break
				end
				if exists then
					cached.any_exists = true
					if cached.broken_reason == nil then
						cached.broken_reason = reason
					end
				end
			end
			client_config_cache[name] = cached
		end
		return cached.value, cached.broken_reason, cached.any_exists, cached.user_won
	end

	-- Initialize debug hooks
	_G._debugging = false
	local function debug_init_cb()
		_G._debugging = true
		mappings.load_extras()
		dapui.open({ reset = true })
	end
	local function debug_terminate_cb()
		if _debugging then
			_G._debugging = false
		end
	end
	local function debug_disconnect_cb()
		if _debugging then
			_G._debugging = false
			dapui.close()
		end
	end
	dap.listeners.after.event_initialized["dapui_config"] = debug_init_cb
	dap.listeners.before.event_terminated["dapui_config"] = debug_terminate_cb
	dap.listeners.before.event_exited["dapui_config"] = debug_terminate_cb
	dap.listeners.before.disconnect["dapui_config"] = debug_disconnect_cb

	-- We need to override nvim-dap's default highlight groups, AFTER requiring nvim-dap for catppuccin.
	vim.api.nvim_set_hl(0, "DapStopped", { fg = colors.green })

	-- TODO: nvim-dap still uses vim.fn.sign_define (no new API yet).
	-- Revisit when nvim-dap adopts vim.diagnostic.config-style signs.
	vim.fn.sign_define(
		"DapBreakpoint",
		{ text = icons.dap.Breakpoint, texthl = "DapBreakpoint", linehl = "", numhl = "" }
	)
	vim.fn.sign_define(
		"DapBreakpointCondition",
		{ text = icons.dap.BreakpointCondition, texthl = "DapBreakpoint", linehl = "", numhl = "" }
	)
	vim.fn.sign_define("DapStopped", { text = icons.dap.Stopped, texthl = "DapStopped", linehl = "", numhl = "" })
	vim.fn.sign_define(
		"DapBreakpointRejected",
		{ text = icons.dap.BreakpointRejected, texthl = "DapBreakpoint", linehl = "", numhl = "" }
	)
	vim.fn.sign_define("DapLogPoint", { text = icons.dap.LogPoint, texthl = "DapLogPoint", linehl = "", numhl = "" })

	-- Everything Mason-flavored loads LAZILY: a session where every adapter
	-- self-validates from $PATH — with no user overrides — must not load
	-- mason.nvim / mason-nvim-dap on the :Dap* tick. First use (the factory
	-- fallback, a phase-2 classification, or a user override's opts
	-- materialization) goes through lazy.nvim's module loader; absence
	-- degrades to client-config/$PATH resolution as before.
	local mason_dap = nil
	local function mason_dap_mod()
		if mason_dap == nil then
			local ok, m = pcall(require, "mason-nvim-dap")
			if ok and type(m) == "table" then
				require("modules.utils").load_plugin("mason-nvim-dap", {
					ensure_installed = {},
					automatic_installation = false,
				})
				mason_dap = m
			else
				mason_dap = false
			end
		end
		return mason_dap or nil
	end
	-- mason-nvim-dap private internals, not a public API: guard each require so
	-- drift degrades to client-config/$PATH resolution instead of aborting.
	-- Failed requires are RECORDED: with presence evidence they are upstream
	-- API drift worth naming; in a Mason-less session the same failures are
	-- expected silence (mason_evidence below tells the two apart).
	local mapping_drift = {}
	local mapping_sibling_ok = false
	local mapping_drift_warned = false
	local function map_or_empty(mod, default)
		local ok, m = pcall(require, mod)
		if ok and type(m) == "table" then
			mapping_sibling_ok = true
			return m
		end
		mapping_drift[#mapping_drift + 1] = mod:match("[^.]+$")
		return default
	end
	---Mason presence evidence without forcing a load: a sibling mapping module
	---loaded, the parent is already in package.loaded, or its file is
	---locatable on the search paths (rtp'd by a failed lazy require attempt).
	local function mason_evidence()
		return mapping_sibling_ok
			or package.loaded["mason-nvim-dap"] ~= nil
			or tools.module_path("mason-nvim-dap") ~= nil
	end
	local mason_maps_cache = nil
	local function mason_maps()
		if not mason_maps_cache then
			mason_maps_cache = {
				source = map_or_empty("mason-nvim-dap.mappings.source", {}),
				adapters = map_or_empty("mason-nvim-dap.mappings.adapters", {}),
				configurations = map_or_empty("mason-nvim-dap.mappings.configurations", {}),
				filetypes = map_or_empty("mason-nvim-dap.mappings.filetypes", {}),
			}
			-- The module may load with the indexed field renamed/removed; normalize
			-- so package_of/unknown_of below never index nil.
			if type(mason_maps_cache.source.nvim_dap_to_package) ~= "table" then
				mason_maps_cache.source.nvim_dap_to_package = {}
			end
		end
		return mason_maps_cache
	end

	---A handler to setup all clients defined under `tool/dap/clients/*.lua`.
	---The factory branch and a user override's opts materialization load
	---mason-nvim-dap; a repo zero-arg client (every adapter in this repo)
	---configures without loading Mason.
	---@param dap_name string
	local function mason_dap_handler(dap_name)
		local custom_handler, broken_reason, _, user_won = load_client_config(dap_name)
		-- No-fall-through contract, enforced by the ONE shared implementation
		-- (tools.usable_or_raise): a broken or wrong-shaped config must never
		-- read as success — that would suppress both the warning and the
		-- install fallback.
		custom_handler = tools.usable_or_raise(custom_handler, broken_reason, {
			label = "client config",
			expected = "a fun(opts)",
			shapes = { ["function"] = true },
		})
		if custom_handler == nil then
			-- No client config: fall back to Mason's factory config, erroring
			-- (level 0) so the resolver reports failures.
			local m = mason_dap_mod()
			if not m then
				error(
					string.format(
						"no client config for `%s` and mason-nvim-dap is unavailable for a default setup",
						dap_name
					),
					0
				)
			end
			local map = mason_maps()
			local config = {
				name = dap_name,
				adapters = map.adapters[dap_name],
				configurations = map.configurations[dap_name],
				filetypes = map.filetypes[dap_name],
			}
			-- default_setup silently no-ops on a nil adapter config: error instead.
			-- No drift CLAIM on the nil lookup itself — upstream legitimately
			-- ships source-only names (js/javadbg/elixir…) with no default
			-- adapter; the remedy is the same either way. Only a recorded
			-- module-level require failure is named as drift.
			if config.adapters == nil then
				local drift = #mapping_drift > 0
						and (" — mapping modules failed to load: " .. table.concat(mapping_drift, ", ") .. " (mason-nvim-dap API drift?)")
					or ""
				error(
					string.format(
						"no client config for `%s`; mason-nvim-dap can install its package but ships no\n"
							.. "default adapter setup for it — add a client config (`tool/dap/clients/%s.lua`\n"
							.. "or `user.configs.dap-clients.%s`)%s",
						dap_name,
						dap_name,
						dap_name,
						drift
					),
					0
				)
			end
			-- Partial mappings drift can hand us configurations without
			-- filetypes: upstream's default_setup guards configurations
			-- (`or {}`) but ipairs()es filetypes whenever configurations are
			-- non-empty — that combination raises ipairs(nil). Normalize both
			-- halves defensively.
			if type(config.configurations) ~= "table" then
				config.configurations = {}
			end
			if type(config.filetypes) ~= "table" then
				config.filetypes = {}
			end
			m.default_setup(config)
		else
			-- Function form (the only other shape usable_or_raise lets through):
			-- the protocol owns its setup. Make sure to set
			-- * dap.adapters.<dap_name> = { your config }
			-- * dap.configurations.<lang> = { your config }
			-- See `codelldb.lua` for a concrete example.
			if user_won then
				-- User-authored override: the historical contract is a PLAIN
				-- table — pairs()/tbl_deep_extend must see the mapping fields,
				-- which a lazy __index proxy cannot provide (LuaJIT has no
				-- __pairs). Costs an eager mason_maps() load only for adapters
				-- the user explicitly overrode.
				local map = mason_maps()
				local opts = {
					name = dap_name,
					adapters = map.adapters[dap_name],
					configurations = map.configurations[dap_name],
					filetypes = map.filetypes[dap_name],
				}
				-- Module-level drift would vanish here: the override "succeeds",
				-- so neither the factory error nor the resolver's missing path
				-- runs. One WARN per session, only with Mason evidence (absence
				-- is not drift) — the override itself still runs: a
				-- self-sufficient one keeps working. A nil field WITHOUT module
				-- drift is the legitimate source-only shape: silent.
				if
					not mapping_drift_warned
					and #mapping_drift > 0
					and (opts.adapters == nil or opts.configurations == nil or opts.filetypes == nil)
					and mason_evidence()
				then
					mapping_drift_warned = true
					vim.notify(
						string.format(
							"mason-nvim-dap mapping modules failed to load: %s — Mason-derived fields\n"
								.. "in the `%s` override opts may be nil (upstream API drift?)",
							table.concat(mapping_drift, ", "),
							dap_name
						),
						vim.log.levels.WARN,
						{ title = "nvim-dap" }
					)
				end
				custom_handler(opts)
			else
				-- Repo clients are zero-arg and must not ENUMERATE opts: the
				-- lazy proxy keeps Mason off the :Dap tick for provisioned
				-- sessions; mapping fields resolve on first ACCESS only.
				custom_handler(setmetatable({ name = dap_name }, {
					__index = function(_, key)
						local map = mason_maps()[key]
						return type(map) == "table" and map[dap_name] or nil
					end,
				}))
			end
		end
	end

	local settings = require("core.settings")

	---Does an explicit client config exist for this adapter (system-resolved)?
	---A config that exists but fails to load still counts — treating it as
	---absent would misread a broken config as an unknown adapter name.
	---@param name string
	---@return boolean
	local function has_client_config(name)
		local value, _, any_exists = load_client_config(name)
		return value ~= nil or any_exists
	end

	-- Discovery-first resolution, shared with LSP and formatters/linters. nvim-dap
	-- has no command registry like nvim-lspconfig, so $PATH detection leans on the
	-- Mason package's declared binaries; configs without a package resolve their own.
	tools.resolve({
		title = "DAP",
		deps = settings.dap_deps,
		-- The shared lazy thunk (tools.default_registry): a fully-provisioned
		-- setup never loads mason-registry.
		registry = tools.default_registry,
		package_of = function(name)
			return mason_maps().source.nvim_dap_to_package[name]
		end,
		binaries_of = function(name, pkg)
			if pkg ~= nil then
				return tools.package_binaries(pkg, name)
			end
			-- No Package, no probe: adapter names are not binary names (`delve`
			-- ships `dlv`). Client configs self-validate.
			return {}
		end,
		---Typo/outdated name vs valid-but-unprovisioned. A client config or mapping means
		---the name is real; an empty map (Mason absent) is untrusted to avoid false typos.
		unknown_of = function(name)
			if has_client_config(name) then
				return false
			end
			local src = mason_maps().source.nvim_dap_to_package
			if next(src) == nil then
				return false
			end
			return src[name] == nil
		end,
		has_local_config = has_client_config,
		---A drifted mappings.source makes package_of return nil, so the name
		---dead-ends in the resolver's reason-less missing branch — name the
		---recorded drift there. Only with Mason evidence: absence is not drift.
		missing_reason_of = function(name)
			if has_client_config(name) or #mapping_drift == 0 or not mason_evidence() then
				return nil
			end
			return "mason-nvim-dap mapping modules failed to load ("
				.. table.concat(mapping_drift, ", ")
				.. ") — cannot derive its Mason package (upstream API drift?)"
		end,
		-- Client configs self-validate, so try an existing config before the Mason
		-- install fallback — python resolves debugpy from a venv $PATH can't see.
		-- The raise on a missing launch binary is the provisioning signal.
		--
		-- CANONICAL availability contract for dap/clients/*.lua (the raise-LAST
		-- clients carry pointer notes back here; keep the two patterns in sync).
		-- Shape enforcement itself lives in tools.usable_or_raise; a
		-- metadata-declared contract ({ attach_capable, binaries }) was
		-- considered and rejected — it would churn the fun(opts) user-override
		-- interface for four clients. Revisit if the client count grows.
		--   * validate FIRST (top of config): launch AND attach both spawn the local
		--     binary, so nothing is worth registering without it — codelldb, lldb.
		--   * raise LAST (bottom of config): attach needs no local binary, so the
		--     attach-capable adapters are registered BEFORE the check and stay
		--     registered when it raises; the raise only signals provisioning (the
		--     warning reasons say remote attach still works) — delve, python.
		local_config_mode = "validates",
		configure = mason_dap_handler,
	})
end
