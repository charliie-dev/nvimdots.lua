-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python
-- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings

-- One optimistic spawn-free provisioning raise per process (see the
-- availability check at the bottom). Module-level on purpose: every configure
-- call (validates, :ToolsRetry, install events, late configure) rebuilds the
-- closure below, and the fallback-to-probe contract needs state that survives
-- re-runs. A config reload (package.loaded wipe) resets it, consistent with
-- re-source semantics elsewhere.
local provision_raise_used = false

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
	-- Negative session cache for the import probe, TTL'd with a finite budget:
	-- launch attempts inside the window, or after the budget is spent, stay
	-- spawn-free (a session where debugpy stays missing pays a bounded total,
	-- then never again). An attempt after the window re-probes while budget
	-- remains, so a pip-installed debugpy is picked up without :ToolsRetry in
	-- the common install-then-retry flow. A success closes the miss-epoch
	-- (found() resets the state) so a later vanished `resolved` starts a fresh
	-- budget. Faster recovery paths stay: the fast probes run FIRST each call
	-- (a Mason install takes over there), a resolver re-configure rebuilds this
	-- whole closure, and :ToolsRetry re-runs the client config.
	local IMPORT_PROBE_TTL_NS = 10 * 1000 * 1000 * 1000 -- 10s between re-probes
	local IMPORT_PROBE_BUDGET = 3 -- post-failure re-probe rounds per miss-epoch
	local import_probe_failed_at = nil
	local import_probe_retries = 0
	local function found(command, args)
		resolved = { command = command, args = args }
		-- Any successful resolution closes the current miss-epoch.
		import_probe_failed_at = nil
		import_probe_retries = 0
		return command, args
	end
	-- One copy for both raise sites so the install guidance can't drift.
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
		if import_probe_failed_at then
			if import_probe_retries >= IMPORT_PROBE_BUDGET then
				return nil -- budget spent: the latch is permanent for this epoch
			end
			if vim.uv.hrtime() - import_probe_failed_at < IMPORT_PROBE_TTL_NS then
				return nil -- inside the window: no respawn
			end
			import_probe_retries = import_probe_retries + 1
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
					if vim.system({ probe_cmd, "-c", "import debugpy" }):wait().code == 0 then
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

	-- Spawn-free evidence that a raise will reach a provisioner. No Mason-root
	-- check on purpose: a clean bootstrap has no data dir yet (the raise is
	-- what creates it), a custom root is unknowable before Mason loads, and a
	-- stale dir proves nothing — the evidence that matters is that BOTH halves
	-- of the provisioning pipeline are managed and present: mason.nvim (the
	-- installer) and mason-nvim-dap.nvim (the python→debugpy mapper) are
	-- independent lazy specs (plugins/completion.lua vs plugins/tool.lua), and
	-- a managed spec whose code is not on disk cannot provision this session.
	-- lazy.core.config is resident (lazy.nvim bootstraps this config); reading
	-- its spec table loads no plugin.
	local function mason_provisionable()
		-- Guard the whole read, not just the require: a drifted module that
		-- returns a non-table (an empty module body makes require return
		-- `true`) must degrade to the probe path, never throw before the
		-- latch/probe below run.
		local ok, lazy_config = pcall(require, "lazy.core.config")
		if not ok or type(lazy_config) ~= "table" or type(lazy_config.plugins) ~= "table" then
			return false
		end
		-- Entries are untrusted for the same reason: a drifted spec shape must
		-- degrade to false, never throw before the latch/probe run.
		local mason = lazy_config.plugins["mason.nvim"]
		local mapper = lazy_config.plugins["mason-nvim-dap.nvim"]
		if
			not (
				type(mason) == "table"
				and type(mapper) == "table"
				and type(mason.dir) == "string"
				and vim.uv.fs_stat(mason.dir) ~= nil
				and type(mapper.dir) == "string"
				and vim.uv.fs_stat(mapper.dir) ~= nil
			)
		then
			return false
		end
		-- The raise can only provision if the mapper still derives a package
		-- for this adapter — checked as "maps to SOME non-empty string", not a
		-- hard-coded package name (an upstream rename must not rot this gate).
		-- Loading Mason modules here keeps the ':Dap tick stays Mason-free'
		-- rule intact in spirit: the gate only runs shimless, where the raise
		-- path's phase 2 loads the same modules moments later on this very
		-- resolution; any drift degrades to the probe path.
		local map_ok, source = pcall(require, "mason-nvim-dap.mappings.source")
		if
			not (
				map_ok
				and type(source) == "table"
				and type(source.nvim_dap_to_package) == "table"
				and type(source.nvim_dap_to_package.python) == "string"
				and source.nvim_dap_to_package.python ~= ""
			)
		then
			return false
		end
		-- ...and only if the registry can actually resolve that package: a
		-- stale mapping (or an unrefreshed/broken registry) would make the
		-- raise dead-end in a mark instead of an install, so those states
		-- keep the probe path.
		local reg_ok, registry = pcall(require, "mason-registry")
		if not reg_ok or type(registry) ~= "table" or type(registry.has_package) ~= "function" then
			return false
		end
		local has_ok, has = pcall(registry.has_package, source.nvim_dap_to_package.python)
		return has_ok and has == true
	end

	-- Availability check LAST (contract: tool/dap/init.lua resolver spec); the
	-- raise is the provisioning signal — the attach adapters stay registered.
	-- The FIRST shimless check with a provisioner present raises WITHOUT the
	-- blocking import probe: probing a system python here would freeze the
	-- shared :Dap tick that validates the OTHER dap clients too (debugging Go
	-- paid for python's probe), and when the raise leads to an install the
	-- probe was pure waste. One shot per process: if provisioning did not
	-- produce the shim (package installed but broken, registry down), every
	-- later validates run — :ToolsRetry, install events, late configure —
	-- falls back to the bounded import probe below, so a capable system
	-- python still validates and clears pending state. A capable system
	-- python on a Mason-less setup passes as before (no needless install).
	if not fast_command() then
		if not provision_raise_used and mason_provisionable() then
			provision_raise_used = true
			error(no_debugpy .. " (remote attach works regardless)", 0)
		end
		if not debugpy_command() then
			error(no_debugpy .. " (remote attach works regardless)", 0)
		end
	end
end
