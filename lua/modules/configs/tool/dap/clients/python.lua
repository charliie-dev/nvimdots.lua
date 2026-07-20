-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python
-- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
return function()
	local dap = require("dap")
	local utils = require("modules.utils.dap")
	local tools = require("modules.utils.tools")
	local is_windows = require("core.global").is_windows
	-- Interpreter candidates probed for a debugpy-capable python; the config-time
	-- availability check and the launch path share one cascade (debugpy_command).
	local py_candidates = is_windows and { "pythonw.exe", "python.exe", "python" } or { "python3", "python" }

	-- Platform-specific venv interpreter layout, in one place.
	---@param root string @A virtualenv root directory.
	---@return string @Absolute path to the venv's python interpreter.
	local function venv_python(root)
		return is_windows and root .. "/Scripts/pythonw.exe" or root .. "/bin/python"
	end

	-- Resolve the debugpy command discovery-first. Higher-priority sources
	-- (Mason venv, adapter shim) are re-probed every call, so a mid-session
	-- install takes over; the cache is consulted LAST purely to spare the
	-- blocking import probe, and a cached hit re-checks existence. (A `pip
	-- uninstall` that keeps the interpreter fails only at import time — accepted.)
	local resolved
	local function found(command, args)
		resolved = { command = command, args = args }
		return command, args
	end
	-- One copy for both raise sites so the install guidance can't drift.
	local no_debugpy = "debugpy not found: no Mason venv, no `debugpy-adapter` on $PATH or in Mason's bin\n"
		.. "dir, and no python able to import debugpy; install debugpy via Mason (`:Mason`)\n"
		.. "or your package manager"

	-- Fast, non-blocking probes only (executable()/exepath()): Mason's managed
	-- venv → `debugpy-adapter` on $PATH. Spawns nothing itself; the import probe
	-- lives in the full cascade below and runs only when these probes miss.
	local function fast_command()
		-- Re-derive the Mason root each call so a debugpy installed mid-session is
		-- picked up: capturing it at config load would freeze it to nil whenever
		-- Mason wasn't resolvable on the first :Dap (its dir not yet created).
		local mason_root = tools.mason_root()
		if mason_root then
			local mason_python = venv_python(mason_root .. "/packages/debugpy/venv")
			if vim.fn.executable(mason_python) == 1 then
				return found(mason_python, { "-m", "debugpy.adapter" })
			end
		end
		-- find_executable reaches a Mason shim even before mason.setup() puts its
		-- bin dir on $PATH; spawn by absolute path (the bare name wouldn't launch).
		local adapter = tools.find_executable("debugpy-adapter")
		if adapter then
			return found(adapter, {})
		end
		-- Cache LAST: it holds whichever source last resolved — possibly a
		-- lower-priority import-probe result — and probing the managed sources
		-- above first is what lets a mid-session install win.
		if resolved then
			if vim.fn.executable(resolved.command) == 1 then
				return resolved.command, resolved.args
			end
			-- The cached binary vanished; drop it and re-run the cascade.
			resolved = nil
		end
		return nil
	end

	-- Negative session cache for the import probe: a session where debugpy
	-- stays missing must not re-pay the blocking interpreter spawns on every
	-- launch attempt. Every recovery path bypasses or resets it: the fast
	-- probes run FIRST each call (a Mason install takes over there), a
	-- resolver re-configure rebuilds this whole closure, and :ToolsRetry
	-- re-runs the client config for a pip-installed debugpy.
	local import_probe_failed = false

	-- Full cascade: fast probes, then a system python that can import debugpy.
	-- The import probe spawns a short-lived python, but only when the fast probes
	-- miss. Both the launch path and the config-time availability check at the
	-- bottom use this cascade, so the two resolutions agree by construction.
	local function debugpy_command()
		local command, args = fast_command()
		if command then
			return command, args
		end
		if import_probe_failed then
			return nil
		end
		-- Last resort: probe interpreter candidates rather than hard-coding one
		-- (pythonw.exe is often absent on a Windows box with only python.exe).
		local probed = {}
		for _, py in ipairs(py_candidates) do
			-- Confirm the module actually imports, not just that the interpreter exists.
			-- Dedup by resolved path so `python`→`python3` symlinks spawn only once.
			if vim.fn.executable(py) == 1 then
				local abs = vim.fn.exepath(py)
				local real = (abs ~= "" and vim.uv.fs_realpath(abs)) or abs
				-- Key by candidate name when exepath came back empty, so one empty
				-- result can't blanket-skip the remaining candidates.
				local key = real ~= "" and real or py
				if not probed[key] then
					probed[key] = true
					local probe_cmd = abs ~= "" and abs or py
					vim.fn.system({ probe_cmd, "-c", "import debugpy" })
					if vim.v.shell_error == 0 then
						-- Spawn by the probed exepath, not its realpath: a venv python is a
						-- symlink and pyvenv.cfg discovery precedes symlink resolution.
						return found(probe_cmd, { "-m", "debugpy.adapter" })
					end
				end
			end
		end
		import_probe_failed = true
		return nil
	end

	dap.adapters.python = function(callback, config)
		if config.request == "attach" then
			local port = (config.connect or config).port
			local host = (config.connect or config).host or "127.0.0.1"
			callback({
				type = "server",
				port = assert(port, "`connect.port` is required for a python `attach` configuration"),
				host = host,
				options = { source_filetype = "python" },
			})
		else
			-- Launch path only: attach uses the server branch above and needs no local debugpy.
			local command, args = debugpy_command()
			if not command then
				error(no_debugpy, 0)
			end
			callback({
				type = "executable",
				command = command,
				args = args,
				options = { source_filetype = "python" },
			})
		end
	end
	dap.configurations.python = {
		{
			-- The first three options are required by nvim-dap
			type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
			request = "launch",
			name = "Debug",
			-- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
			console = "integratedTerminal",
			program = utils.input_file_path(),
			pythonPath = function()
				local venv = vim.env.CONDA_PREFIX
				if venv then
					return venv_python(venv)
				else
					return is_windows and "pythonw.exe" or "python3"
				end
			end,
		},
		{
			-- NOTE: This setting is for people using venv
			type = "python",
			request = "launch",
			name = "Debug (using venv)",
			-- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
			console = "integratedTerminal",
			program = utils.input_file_path(),
			pythonPath = function()
				-- Prefer the venv that is defined by the designated environment variable.
				local cwd, venv = vim.uv.cwd(), vim.env.VIRTUAL_ENV
				local python = venv and venv_python(venv) or ""
				if vim.fn.executable(python) == 1 then
					return python
				end

				-- Otherwise, fall back to check if there are any local venvs available.
				venv = vim.fn.isdirectory(cwd .. "/venv") == 1 and cwd .. "/venv" or cwd .. "/.venv"
				python = venv_python(venv)
				if vim.fn.executable(python) == 1 then
					return python
				else
					return is_windows and "pythonw.exe" or "python3"
				end
			end,
		},
	}

	-- Availability check LAST (contract: tool/dap/init.lua resolver spec); the
	-- raise is the provisioning signal — the attach adapters stay registered.
	-- A capable system python passes (no needless install); the bounded import
	-- probe spawns only when the fast probes miss.
	if not debugpy_command() then
		error(no_debugpy .. " (remote attach works regardless)", 0)
	end
end
