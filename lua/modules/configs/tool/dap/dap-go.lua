local configured = false

local function canonical_executable(path, label)
	assert(type(path) == "string" and path ~= "", string.format("`%s` is not executable", label))
	local canonical = assert(vim.uv.fs_realpath(path), string.format("failed to resolve `%s`", label))
	assert(vim.fn.executable(canonical) == 1, string.format("`%s` is not executable", canonical))
	return canonical
end

local function trusted_executable(name)
	return canonical_executable(vim.fn.exepath(name), name)
end

return function()
	if configured then
		return
	end
	configured = true

	local ok, err = xpcall(function()
		local dap = require("dap")
		local dlv = trusted_executable("dlv")

		require("dap-go").setup({
			delve = {
				path = dlv,
			},
		})

		local upstream = assert(dap.adapters.go, "dap-go did not register its adapter")
		assert(type(upstream) == "function", "dap-go adapter must be a factory")

		dap.adapters.go = function(callback, config)
			assert(type(config) == "table", "dap-go configuration must be a table")
			if config.host ~= nil or config.port ~= nil then
				error("dap-go host and port overrides are disabled")
			end

			return upstream(function(adapter)
				local executable = type(adapter) == "table" and adapter.executable or nil
				local args = type(executable) == "table" and executable.args or nil
				assert(adapter.port == "${port}", "dap-go must use an ephemeral port")
				assert(executable.command == dlv, "dap-go must use the trusted dlv path")
				assert(
					type(args) == "table" and args[1] == "dap" and args[2] == "-l" and args[3] == "127.0.0.1:${port}",
					"dap-go must listen on the default loopback endpoint"
				)
				callback(adapter)
			end, config)
		end
	end, debug.traceback)

	if not ok then
		configured = false
		error(err)
	end
end
