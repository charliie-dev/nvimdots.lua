-- https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(via--codelldb)
return function()
	local dap = require("dap")
	local utils = require("modules.utils.dap")
	local is_windows = require("core.global").is_windows

	-- Self-validate at config time (validate FIRST — contract: tool/dap/init.lua
	-- resolver spec): launch AND attach both spawn the local binary, so
	-- unlike delve/python nothing is worth registering without it — error if missing.
	local command =
		require("modules.utils.tools").exepath_or_error("codelldb", "install it via Mason or your package manager")
	dap.adapters.codelldb = {
		type = "server",
		port = "${port}",
		executable = {
			command = command,
			args = { "--port", "${port}" },
			detached = not is_windows,
		},
	}
	dap.configurations.c = {
		{
			name = "Debug",
			type = "codelldb",
			request = "launch",
			program = utils.input_exec_path(),
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			terminal = "integrated",
		},
		{
			name = "Debug (with args)",
			type = "codelldb",
			request = "launch",
			program = utils.input_exec_path(),
			args = utils.input_args(),
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			terminal = "integrated",
		},
		{
			name = "Attach to a running process",
			type = "codelldb",
			request = "attach",
			program = utils.input_exec_path(),
			stopOnEntry = false,
			waitFor = true,
		},
	}
	dap.configurations.cpp = dap.configurations.c
	dap.configurations.rust = dap.configurations.c
end
