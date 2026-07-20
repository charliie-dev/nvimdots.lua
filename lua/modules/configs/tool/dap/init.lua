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
	---Load the first usable client config (user override, then repo preset) via
	---the shared first-usable loader, memoized per adapter: the resolver consults
	---it from several predicates (has_local_config, unknown_of) plus the handler,
	---and an uncached miss would re-run a failed require each time.
	---@param name string
	---@return any value, string|nil broken_reason, boolean any_exists
	local function load_client_config(name)
		local cached = client_config_cache[name]
		if not cached then
			local value, broken_reason, any_exists = tools.load_first_usable(client_modules(name), "nvim-dap")
			cached = { value = value, broken_reason = broken_reason, any_exists = any_exists }
			client_config_cache[name] = cached
		end
		return cached.value, cached.broken_reason, cached.any_exists
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
	-- self-validates from $PATH must not load mason.nvim / mason-nvim-dap on
	-- the :Dap* tick. First use (the factory fallback or a phase-2
	-- classification) goes through lazy.nvim's module loader; absence degrades
	-- to client-config/$PATH resolution as before.
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
	local function map_or_empty(mod, default)
		local ok, m = pcall(require, mod)
		return (ok and type(m) == "table") and m or default
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
	---Only the factory branch touches mason-nvim-dap: a client-config'd adapter
	---(every adapter in this repo) configures without loading Mason.
	---@param dap_name string
	local function mason_dap_handler(dap_name)
		local custom_handler, broken_reason = load_client_config(dap_name)
		-- No-fall-through contract, enforced by the ONE shared implementation
		-- (tools.usable_or_raise, also used by mason_lsp_handler): a broken or
		-- wrong-shaped config must never read as success — that would suppress
		-- both the warning and the install fallback.
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
			if config.adapters == nil then
				error(
					string.format(
						"no client config for `%s` and mason-nvim-dap has no adapter definition for it",
						dap_name
					),
					0
				)
			end
			-- Partial mappings drift can hand us configurations without
			-- filetypes (or vice versa); default_setup ipairs() both
			-- unconditionally. Degrade to whatever half is present instead of
			-- a raw ipairs(nil) raise.
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
			-- The opts table keeps the historical contract (name + the Mason
			-- mapping fields) without the eager Mason cost: mapping fields load
			-- on first ACCESS, so the zero-arg repo clients never touch Mason
			-- while a user override reading opts.adapters still gets them.
			custom_handler(setmetatable({ name = dap_name }, {
				__index = function(_, key)
					local map = mason_maps()[key]
					return type(map) == "table" and map[dap_name] or nil
				end,
			}))
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
		-- Lazy thunk so a fully-provisioned setup never loads mason-registry.
		registry = function()
			local ok, resolved = pcall(require, "mason-registry")
			return ok and resolved or nil
		end,
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
		-- Client configs self-validate, so try an existing config before the Mason
		-- install fallback — python resolves debugpy from a venv $PATH can't see.
		-- The raise on a missing launch binary is the provisioning signal.
		--
		-- CANONICAL availability contract for dap/clients/*.lua (referenced by the
		-- one-line notes in each client; keep the two patterns in sync here).
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
