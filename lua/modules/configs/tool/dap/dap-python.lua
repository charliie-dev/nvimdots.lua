local configured = false

local function canonical_executable(path, label)
	assert(type(path) == "string" and path ~= "", string.format("`%s` is not executable", label))
	local canonical = assert(vim.uv.fs_realpath(path), string.format("failed to resolve `%s`", label))
	assert(vim.fn.executable(canonical) == 1, string.format("`%s` is not executable", canonical))
	return canonical
end

local function is_absolute_path(path)
	return path:sub(1, 1) == "/" or path:match("^%a:[/\\]") ~= nil or path:match("^[/\\][/\\]") ~= nil
end

local function python_executable(path, label)
	assert(
		type(path) == "string" and path ~= "" and is_absolute_path(path),
		string.format("`%s` must be absolute", label)
	)
	local normalized = vim.fs.normalize(path)
	assert(vim.uv.fs_realpath(normalized), string.format("failed to resolve `%s`", label))
	assert(vim.fn.executable(normalized) == 1, string.format("`%s` is not executable", normalized))
	return normalized
end

local function trusted_executable(name)
	return canonical_executable(vim.fn.exepath(name), name)
end

local function current_project_python()
	local is_windows = require("core.global").is_windows
	local buffer = vim.api.nvim_buf_get_name(0)
	local cwd = vim.uv.cwd() or vim.fn.getcwd()
	local start = buffer ~= "" and vim.fs.dirname(vim.fs.normalize(buffer)) or cwd
	local project = vim.fs.root(start, {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		".git",
	}) or start
	local function active_environment_python(prefix, conda)
		if type(prefix) ~= "string" or prefix == "" then
			return nil
		end
		local python
		if is_windows then
			python = conda and prefix .. "/python.exe" or prefix .. "/Scripts/python.exe"
		else
			python = prefix .. "/bin/python"
		end
		if vim.fn.executable(python) == 1 then
			return python_executable(python, "active Python interpreter")
		end
	end

	local virtual_env = active_environment_python(vim.env.VIRTUAL_ENV, false)
	if virtual_env then
		return virtual_env
	end
	local conda = active_environment_python(vim.env.CONDA_PREFIX, true)
	if conda then
		return conda
	end

	local roots = {}
	local seen = {}

	for _, root in ipairs({ start, project }) do
		if root and not seen[root] then
			seen[root] = true
			roots[#roots + 1] = root
		end
	end

	for _, root in ipairs(roots) do
		for _, folder in ipairs({ "venv", ".venv", "env", ".env" }) do
			local venv = root .. "/" .. folder
			local stat = vim.uv.fs_stat(venv)
			if stat and stat.type == "directory" then
				local python = is_windows and venv .. "/Scripts/python.exe" or venv .. "/bin/python"
				return python_executable(python, "project Python interpreter")
			end
		end
	end

	local name = is_windows and "python.exe" or "python3"
	return python_executable(vim.fn.exepath(name), name)
end

local function contains_listen(value, seen)
	if type(value) ~= "table" then
		return false
	end
	seen = seen or {}
	if seen[value] then
		return false
	end
	seen[value] = true
	if rawget(value, "listen") ~= nil then
		return true
	end
	for _, nested in next, value do
		if contains_listen(nested, seen) then
			return true
		end
	end
	return false
end

local function validate_python_command(command)
	assert(type(command) == "table" and getmetatable(command) == nil, "dap-python `python` must be a plain list")

	local count = 0
	for key, value in next, command do
		assert(type(key) == "number" and key >= 1 and key % 1 == 0, "dap-python `python` must be a dense list")
		assert(type(value) == "string" and value ~= "", "dap-python `python` entries must be nonempty strings")
		count = count + 1
	end
	assert(count > 0, "dap-python `python` must not be empty")

	local validated = {}
	for index = 1, count do
		local value = rawget(command, index)
		assert(value ~= nil, "dap-python `python` must be a dense list")
		validated[index] = value
	end
	assert(is_absolute_path(validated[1]), "dap-python `python` interpreter must be absolute")
	validated[1] = python_executable(validated[1], "Python interpreter")
	return validated
end

return function()
	if configured then
		return
	end
	configured = true

	local ok, err = xpcall(function()
		local dap = require("dap")
		local dap_python = require("dap-python")
		local is_windows = require("core.global").is_windows
		local uv = trusted_executable("uv")
		local basename = uv:gsub("\\", "/"):match("([^/]+)$")
		assert(basename and basename:lower() == (is_windows and "uv.exe" or "uv"), "unexpected trusted uv path")

		dap_python.resolve_python = current_project_python
		dap_python.setup(is_windows and "uv" or uv)

		local upstream = assert(dap.adapters.python, "dap-python did not register its adapter")
		assert(type(upstream) == "function", "dap-python adapter must be a factory")

		local function guarded(callback, config)
			assert(type(config) == "table", "dap-python configuration must be a table")
			if config.request == "attach" then
				if contains_listen(config) then
					error("dap-python listen endpoints are disabled")
				end
				local endpoint = config.connect or config
				assert(type(endpoint) == "table", "dap-python attach endpoint must be a table")
				local port = endpoint.port
				assert(
					type(port) == "number" and port % 1 == 0 and port >= 1 and port <= 65535,
					"dap-python attach port must be an integer from 1 through 65535"
				)
				local host = endpoint.host or "127.0.0.1"
				if host ~= "127.0.0.1" and host ~= "::1" then
					error("dap-python attach host must be literal loopback")
				end
			end

			return upstream(function(adapter)
				assert(type(adapter) == "table", "dap-python adapter must be a table")
				if adapter.type == "executable" then
					assert(
						vim.deep_equal(adapter.args, { "run", "--with", "debugpy", "python", "-m", "debugpy.adapter" }),
						"dap-python must use the reviewed uv debugpy arguments"
					)
					if is_windows then
						assert(adapter.command == "uv", "dap-python did not select its uv branch")
						adapter.command = uv
					else
						assert(adapter.command == uv, "dap-python must use the trusted uv path")
					end
				end

				local enrich_config = assert(adapter.enrich_config, "dap-python did not register config enrichment")
				assert(type(enrich_config) == "function", "dap-python config enrichment must be a function")
				adapter.enrich_config = function(enriched, on_config)
					local guarded_enriched = {}
					for key, value in next, enriched do
						guarded_enriched[key] = value
					end
					if guarded_enriched.pythonPath == nil and guarded_enriched.python == nil then
						guarded_enriched.pythonPath = current_project_python()
					end
					return enrich_config(guarded_enriched, function(final)
						assert(type(final) == "table", "dap-python enriched configuration must be a table")
						if final.pythonPath ~= nil then
							final.pythonPath = python_executable(final.pythonPath, "Python interpreter")
						end
						if final.python ~= nil then
							final.python = validate_python_command(final.python)
						end
						if final.pythonPath == nil and final.python == nil then
							error("dap-python did not resolve a Python interpreter")
						end
						on_config(final)
					end)
				end

				callback(adapter)
			end, config)
		end

		dap.adapters.python = guarded
		dap.adapters.debugpy = guarded
	end, debug.traceback)

	if not ok then
		configured = false
		error(err)
	end
end
