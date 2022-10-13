vim.api.nvim_command([[packadd nvim-dap-ui]])
local dap = require("dap")
local dapui = require("dapui")
local dap_icon = require("modules.ui.icons").dap

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.after.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.after.event_exited["dapui_config"] = function()
	dapui.close()
end

-- We need to override nvim-dap's default highlight groups, AFTER requiring nvim-dap for catppuccin.
vim.api.nvim_set_hl(0, "DapStopped", { fg = "#ABE9B3" })

vim.fn.sign_define(
	"DapBreakpoint",
	{ text = dap_icon.Breakpoint, texthl = "DiagnosticSignError", linehl = "", numhl = "" }
)
vim.fn.sign_define(
	"DapBreakpointCondition",
	{ text = dap_icon.BreakpointCondition, texthl = "DapBreakpoint", linehl = "", numhl = "" }
)
vim.fn.sign_define("DapStopped", { text = dap_icon.Stopped, texthl = "DapStopped", linehl = "", numhl = "" })
vim.fn.sign_define(
	"DapBreakpointRejected",
	{ text = dap_icon.BreakpointRejected, texthl = "DapBreakpoint", linehl = "", numhl = "" }
)
vim.fn.sign_define("DapLogPoint", { text = dap_icon.LogPoint, texthl = "DapLogPoint", linehl = "", numhl = "" })

-- config lang adaptors
require("modules.tools.dap.dap-cpp-c-rust")
require("modules.tools.dap.dap-python")
require("modules.tools.dap.dap-go")
