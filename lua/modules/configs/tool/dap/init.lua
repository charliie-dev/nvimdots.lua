return function()
	local dap = require("dap")
	local dapui = require("dapui")
	local mason_dap = require("mason-nvim-dap")

	local icons = { dap = require("modules.utils.icons").get("dap") }
	local colors = require("modules.utils").get_palette()
	local mappings = require("tool.dap.dap-keymap")

	-- Initialize debug hooks
	_G._debugging = false
	local function debug_init_cb()
		_G._debugging = true
		mappings.load_extras()
		dapui.open({ reset = true })
	end
	local teardown_pending = false
	local function debug_session_cb(old_session, new_session)
		if new_session ~= nil or old_session == nil or teardown_pending then
			return
		end
		teardown_pending = true
		vim.schedule(function()
			teardown_pending = false
			if dap.session() == nil then
				_G._debugging = false
				dapui.close()
			end
		end)
	end
	dap.listeners.after.event_initialized["dapui_config"] = debug_init_cb
	dap.listeners.on_session["dapui_config"] = debug_session_cb

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

	local configured = {}
	local function optional_module(module)
		local ok, value = pcall(require, module)
		if ok then
			return true, value
		end
		local load_error = tostring(value)
		if load_error:find("module '" .. module .. "' not found:", 1, true) then
			return false, nil
		end
		error(string.format("Failed to load DAP client module [%s]: %s", module, load_error), 0)
	end

	---A handler to setup all clients defined under `tool/dap/clients/*.lua`
	---@param config table
	local function mason_dap_handler(config)
		assert(type(config) == "table", "mason-nvim-dap handler config must be a table")
		assert(type(config.name) == "string" and config.name ~= "", "mason-nvim-dap handler requires a name")
		if config.name == "delve" or config.name == "python" or config.name == "lldb" then
			return
		end
		local dap_name = config.name
		if configured[dap_name] then
			return
		end
		local user_present, custom_handler = optional_module("user.configs.dap-clients." .. dap_name)
		if not user_present then
			custom_handler = select(2, optional_module("tool.dap.clients." .. dap_name))
		end
		if custom_handler == nil then
			mason_dap.default_setup(config)
		elseif type(custom_handler) == "function" then
			custom_handler(config)
		else
			error(
				string.format(
					"DAP client definition for [%s] must return a function (got '%s')",
					dap_name,
					type(custom_handler)
				),
				0
			)
		end
		configured[dap_name] = true
	end

	local function codelldb_mapping(module)
		local ok, mapping = pcall(require, module)
		if ok and type(mapping) == "table" then
			return mapping.codelldb
		end
	end

	-- Register the verifiable adapter even when its executable is supplied outside Mason or currently missing.
	mason_dap_handler({
		name = "codelldb",
		adapters = codelldb_mapping("mason-nvim-dap.mappings.adapters"),
		configurations = codelldb_mapping("mason-nvim-dap.mappings.configurations"),
		filetypes = codelldb_mapping("mason-nvim-dap.mappings.filetypes"),
	})

	require("modules.utils").load_plugin("mason-nvim-dap", {
		ensure_installed = {},
		automatic_installation = false,
		handlers = { mason_dap_handler },
	})
end
