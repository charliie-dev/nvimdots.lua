local failures, tests_run = {}, 0

local function test(name, callback)
	tests_run = tests_run + 1
	local ok, err = xpcall(callback, debug.traceback)
	if ok then
		print("PASS " .. name)
	else
		failures[#failures + 1] = name .. ": " .. err
		print("FAIL " .. name)
	end
end

-- Run callback(expected) inside a temporary project whose .venv/bin/python links to python3, with
-- its main.py as the current buffer and no active virtualenv or conda environment.
local function with_project(callback)
	require("lazy.core.loader").load("nvim-dap-python", { cmd = "test" }, { force = true })
	local project = vim.fn.tempname()
	local original_virtual_env = vim.env.VIRTUAL_ENV
	local original_conda_prefix = vim.env.CONDA_PREFIX
	local original_buffer = vim.api.nvim_get_current_buf()

	local ok, err = xpcall(function()
		vim.fn.mkdir(project .. "/.git", "p")
		vim.fn.mkdir(project .. "/venv", "p")
		vim.fn.mkdir(project .. "/.venv/bin", "p")
		vim.fn.writefile({ "" }, project .. "/main.py")

		local python = vim.fn.exepath("python3")
		assert(python ~= "", "python3 is required")
		local linked, link_err = vim.uv.fs_symlink(python, project .. "/.venv/bin/python")
		assert(linked, link_err)

		vim.env.VIRTUAL_ENV = nil
		vim.env.CONDA_PREFIX = nil
		vim.cmd.edit(vim.fn.fnameescape(project .. "/main.py"))

		callback(vim.fs.normalize(assert(vim.uv.fs_realpath(project)) .. "/.venv/bin/python"))
	end, debug.traceback)

	vim.env.VIRTUAL_ENV = original_virtual_env
	vim.env.CONDA_PREFIX = original_conda_prefix
	pcall(vim.api.nvim_set_current_buf, original_buffer)
	vim.fn.delete(project, "rf")
	assert(ok, err)
end

test("project Python resolver skips incomplete environment directories", function()
	with_project(function(expected)
		local resolved = require("dap-python").resolve_python()
		assert(resolved == expected, string.format("resolver returned %q instead of %q", resolved, expected))
	end)
end)

test("launch configs get the project interpreter as debugpy's python list", function()
	with_project(function(expected)
		local function enrich(config)
			local final
			require("dap").adapters.python(function(adapter)
				adapter.enrich_config(config, function(result)
					final = result
				end)
			end, config)
			assert(
				vim.wait(2000, function()
					return final ~= nil
				end),
				"enrich_config did not finish"
			)
			return final
		end

		local filled = enrich({ type = "python", request = "launch", program = "main.py" })
		assert(vim.deep_equal(filled.python, { expected }), "python: " .. vim.inspect(filled.python))
		assert(filled.pythonPath == nil, "the legacy pythonPath was filled too: " .. tostring(filled.pythonPath))

		-- A configuration's own interpreter is kept, in whichever field it uses.
		local python3 = vim.fs.normalize(vim.fn.exepath("python3"))
		local legacy = enrich({ type = "python", request = "launch", pythonPath = python3 })
		assert(legacy.pythonPath == python3 and legacy.python == nil, "pythonPath config: " .. vim.inspect(legacy))
		local list = enrich({ type = "python", request = "launch", python = { python3, "-X", "dev" } })
		assert(vim.deep_equal(list.python, { python3, "-X", "dev" }), "python config: " .. vim.inspect(list.python))
		assert(list.pythonPath == nil, "python config also got pythonPath")
	end)
end)

if #failures > 0 then
	vim.api.nvim_err_writeln(table.concat(failures, "\n"))
	vim.cmd.cquit(1)
end

print(string.format("dap_python_spec: %d tests passed", tests_run))
