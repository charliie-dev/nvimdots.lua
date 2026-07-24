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

	-- Resolve the debugpy command discovery-first. The higher-priority source
	-- (the `debugpy-adapter` shim) is re-probed every call, so a mid-session
	-- install takes over; the cache is consulted LAST purely to spare the
	-- blocking import probe, and a cached hit re-checks existence. (A `pip
	-- uninstall` that keeps the interpreter fails only at import time — accepted.)
	local resolved
	-- Negative session cache for the import probe, on a single flat TTL:
	-- launch attempts inside the window stay spawn-free; each expiry allows
	-- one re-probe, so the common install-then-retry flow picks a
	-- pip-installed debugpy up within seconds. Deliberately NOT a permanent
	-- latch: a name no longer in the resolver's pending set has no
	-- :ToolsRetry path back here, so a dead-forever cache would make a later
	-- `pip install debugpy` unreachable without a restart. Every probe is
	-- itself bounded (5s :wait) and only runs on explicit launch attempts —
	-- the accepted worst case is one bounded probe per window while launches
	-- keep failing. Faster recovery paths stay: the fast probes run FIRST
	-- each call (a Mason install takes over there), and a resolver
	-- re-configure rebuilds this whole closure.
	local IMPORT_PROBE_TTL_NS = 10 * 1000 * 1000 * 1000 -- flat window between re-probes
	local import_probe_failed_at = nil
	local function found(command, args)
		resolved = { command = command, args = args }
		-- Any successful resolution clears the failure window.
		import_probe_failed_at = nil
		return command, args
	end
	-- One copy for all raise sites so the install guidance can't drift.
	local no_debugpy = "debugpy not found: no `debugpy-adapter` shim on $PATH or in Mason's bin dir,\n"
		.. "and no python able to import debugpy; install debugpy via Mason (`:Mason`)\n"
		.. "or your package manager"

	-- Fast, non-blocking probes only (executable()/exepath()): the
	-- `debugpy-adapter` shim, then the cached last resolution. Spawns nothing
	-- itself; the import probe lives in the full cascade below and runs only
	-- when these probes miss. The shim is the SUPPORTED Mason surface — it is
	-- declared by the debugpy package spec and exists exactly when the managed
	-- venv does, so no probe hardcodes Mason's packages/<name>/venv layout.
	-- (Accepted nuance: on Windows the shim spawns via .cmd instead of
	-- pythonw.exe, so no console-window suppression on that path.)
	local function fast_command()
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

	-- Full cascade: fast probes, then a system python that can import debugpy.
	-- The import probe spawns a short-lived python, but only when the fast probes
	-- miss. Both the launch path and the config-time availability check at the
	-- bottom use this cascade, so the two resolutions agree by construction.
	local function debugpy_command()
		local command, args = fast_command()
		if command then
			return command, args
		end
		if import_probe_failed_at and vim.uv.hrtime() - import_probe_failed_at < IMPORT_PROBE_TTL_NS then
			-- Inside the window: no respawn. (The stamp at the cascade's end
			-- restarts the window whenever a round misses again.)
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
					-- vim.system, not vim.fn.system: the exit code stays local
					-- instead of round-tripping through the v:shell_error global
					-- (repo convention — core/pack.lua, servers/gopls.lua).
					-- Bounded wait: this runs synchronously on the :Dap* setup
					-- tick, and a hung interpreter (dead network FS, broken
					-- shim) would otherwise freeze the editor. On timeout the
					-- probe is SIGKILLed with code 124 — a failed probe, so
					-- resolution falls through to the remaining candidates.
					if vim.system({ probe_cmd, "-c", "import debugpy" }):wait(5000).code == 0 then
						-- Spawn by the probed exepath, not its realpath: a venv python is a
						-- symlink and pyvenv.cfg discovery precedes symlink resolution.
						return found(probe_cmd, { "-m", "debugpy.adapter" })
					end
				end
			end
		end
		import_probe_failed_at = vim.uv.hrtime()
		return nil
	end

	dap.adapters.python = function(callback, config)
		if config.request == "attach" then
			-- Shared shape validation (utils.attach_endpoint): a malformed
			-- port/host errors clearly at config time instead of surfacing as
			-- an opaque TCP failure. No default port — attach must name one.
			local host, port = utils.attach_endpoint(config.connect or config, { label = "python attach" })
			callback({
				type = "server",
				port = port,
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
			type = "python", -- links to the adapter definition: `dap.adapters.python`
			request = "launch",
			name = "Debug",
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
			type = "python",
			request = "launch",
			name = "Debug (using venv)",
			console = "integratedTerminal",
			program = utils.input_file_path(),
			pythonPath = function()
				-- Prefer the venv that is defined by the designated environment variable.
				local cwd, venv = vim.uv.cwd(), vim.env.VIRTUAL_ENV
				local python = venv and venv_python(venv) or ""
				if vim.fn.executable(python) == 1 then
					return python
				end

				-- Otherwise fall back to any local venv — guarded: vim.uv.cwd()
				-- returns nil when the process working directory was deleted.
				if cwd then
					venv = vim.fn.isdirectory(cwd .. "/venv") == 1 and cwd .. "/venv" or cwd .. "/.venv"
					python = venv_python(venv)
					if vim.fn.executable(python) == 1 then
						return python
					end
				end
				return is_windows and "pythonw.exe" or "python3"
			end,
		},
	}

	-- Availability check LAST (contract: tool/dap/init.lua resolver spec); the
	-- raise is the provisioning signal — the attach adapters stay registered.
	-- One bounded cascade decides (typical cost with a python present is a
	-- fast `import debugpy` exit; the 5s :wait only bites on pathological
	-- hangs), so config-time and launch-time resolution agree by construction,
	-- and a capable system python is honored BEFORE any Mason install — the
	-- discovery-first $PATH-wins contract. A spawn-free "raise early when
	-- Mason can provision" gate (e6f08f8) sat here before: it skipped the
	-- probe and auto-installed Mason's debugpy over a working pip copy, and
	-- its evidence chain load-bore two private upstream surfaces
	-- (lazy.core.config, mason-nvim-dap.mappings.source) — reversed on
	-- purpose.
	if not debugpy_command() then
		error(no_debugpy .. " (remote attach works regardless)", 0)
	end
end
