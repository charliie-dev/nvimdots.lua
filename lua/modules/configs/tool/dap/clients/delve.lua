-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go-using-delve-directly
-- https://github.com/golang/vscode-go/blob/master/docs/debugging.md
return function()
	local dap = require("dap")
	local utils = require("modules.utils.dap")
	local is_windows = require("core.global").is_windows

	-- Use delve's built-in DAP server (`dlv dap`) directly, no separate go-debug-adapter.
	-- `dlv` resolves lazily on the spawn path: remote attach needs no local binary, so
	-- the adapter registers even when it's absent.

	---A function adapter (over a static table) so a remote `attach` config can
	---connect to an already-running `dlv dap` instead of spawning a local one.
	---@param callback fun(adapter: table)
	---@param config table
	local function delve_adapter(callback, config)
		if config.request == "attach" and config.mode == "remote" then
			-- Default when unset (38697 is the conventional example port from the
			-- nvim-dap wiki, not a delve default), but a malformed user port
			-- errors rather than silently falling back to it.
			local port = 38697
			if config.port ~= nil then
				local n = tonumber(config.port)
				if not n or n ~= math.floor(n) or n < 1 or n > 65535 then
					error(
						string.format(
							"delve remote attach: invalid `port` %s (want an integer 1-65535)",
							vim.inspect(config.port)
						),
						0
					)
				end
				port = n
			end
			-- Same contract as `port` above: a malformed value errors at config
			-- time instead of surfacing as an opaque connection failure. Hosts
			-- are free-form (hostname/IPv4/IPv6), so only the shape is checked.
			local host = "127.0.0.1"
			if config.host ~= nil then
				if type(config.host) ~= "string" or config.host == "" then
					error(
						string.format(
							"delve remote attach: invalid `host` %s (want a non-empty string)",
							vim.inspect(config.host)
						),
						0
					)
				end
				host = config.host
			end
			callback({
				type = "server",
				host = host,
				port = port,
			})
		else
			-- Resolve lazily so a dlv installed after config load is picked up without reconfiguring.
			local command = require("modules.utils.tools").exepath_or_error(
				"dlv",
				"install delve via Mason or your package manager"
			)
			callback({
				type = "server",
				port = "${port}",
				executable = {
					command = command,
					args = { "dap", "-l", "127.0.0.1:${port}" },
					detached = not is_windows,
				},
			})
		end
	end

	-- Register under both names: the configurations below use `type = "go"`, while
	-- mason-nvim-dap / other integrations reference the adapter as `delve`.
	dap.adapters.go = delve_adapter
	dap.adapters.delve = delve_adapter

	dap.configurations.go = {
		{
			type = "go",
			name = "Debug (file)",
			request = "launch",
			cwd = "${workspaceFolder}",
			program = utils.input_file_path(),
			console = "integratedTerminal",
			showLog = true,
			showRegisters = true,
			stopOnEntry = false,
		},
		{
			type = "go",
			name = "Debug (file with args)",
			request = "launch",
			cwd = "${workspaceFolder}",
			program = utils.input_file_path(),
			args = utils.input_args(),
			console = "integratedTerminal",
			showLog = true,
			showRegisters = true,
			stopOnEntry = false,
		},
		{
			type = "go",
			name = "Debug (executable)",
			request = "launch",
			cwd = "${workspaceFolder}",
			program = utils.input_exec_path(),
			args = utils.input_args(),
			console = "integratedTerminal",
			mode = "exec",
			showLog = true,
			showRegisters = true,
			stopOnEntry = false,
		},
		{
			type = "go",
			name = "Debug (test file)",
			request = "launch",
			cwd = "${workspaceFolder}",
			program = utils.input_file_path(),
			console = "integratedTerminal",
			mode = "test",
			showLog = true,
			showRegisters = true,
			stopOnEntry = false,
		},
		{
			type = "go",
			name = "Debug (using go.mod)",
			request = "launch",
			cwd = "${workspaceFolder}",
			program = "./${relativeFileDirname}",
			console = "integratedTerminal",
			mode = "test",
			showLog = true,
			showRegisters = true,
			stopOnEntry = false,
		},
	}

	-- Availability check LAST (contract: tool/dap/init.lua resolver spec); the raise
	-- is the provisioning signal — the attach-capable adapters above stay registered.
	require("modules.utils.tools").exepath_or_error(
		"dlv",
		"local `dlv dap` launch is unavailable until installed (remote attach still works)"
	)
end
