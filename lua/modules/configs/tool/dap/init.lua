return function()
	local dap = require("dap")
	local dapui = require("dapui")

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

	local module = "user.configs.dap-clients.codelldb"
	local ok, codelldb = pcall(require, module)
	if not ok then
		local load_error = tostring(codelldb)
		if not load_error:find("module '" .. module .. "' not found:", 1, true) then
			error(string.format("Failed to load DAP client module [%s]: %s", module, load_error), 0)
		end
		codelldb = require("tool.dap.clients.codelldb")
	end
	assert(type(codelldb) == "function", "DAP client definition for [codelldb] must return a function")
	codelldb({ name = "codelldb" })
end
