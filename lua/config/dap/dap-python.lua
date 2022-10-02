local function isempty(s)
	return s == nil or s == ""
end

local dap = require("dap")
dap.adapters.python = {
	type = "executable",
	command = "python",
	args = { "-m", "debugpy.adapter" },
}
dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch file",
		program = "${file}",
		pythonPath = function()
      if not isempty(vim.env.CONDA_zPREFIX) then
        return vim.env.CONDA_PREFIX .. "/bin/python"
      -- print(vim.g.python3_host_prog)
      else
        return "/usr/bin/python3"
      end
		end,
	},
}
