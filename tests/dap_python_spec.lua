local failures = {}

local function test(name, callback)
	local ok, err = xpcall(callback, debug.traceback)
	if ok then
		print("PASS " .. name)
	else
		failures[#failures + 1] = name .. ": " .. err
		print("FAIL " .. name)
	end
end

test("project Python resolver skips incomplete environment directories", function()
	require("lazy.core.loader").load("nvim-dap-python", { cmd = "test" }, { force = true })
	local resolve_python = require("dap-python").resolve_python
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

		local resolved = resolve_python()
		local expected = vim.fs.normalize(assert(vim.uv.fs_realpath(project)) .. "/.venv/bin/python")
		assert(resolved == expected, string.format("resolver returned %q instead of %q", resolved, expected))
	end, debug.traceback)

	vim.env.VIRTUAL_ENV = original_virtual_env
	vim.env.CONDA_PREFIX = original_conda_prefix
	pcall(vim.api.nvim_set_current_buf, original_buffer)
	vim.fn.delete(project, "rf")
	assert(ok, err)
end)

if #failures > 0 then
	vim.api.nvim_err_writeln(table.concat(failures, "\n"))
	vim.cmd.cquit(1)
end

print("dap_python_spec: 1 test passed")
