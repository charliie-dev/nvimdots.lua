local dap = require("dap")

local function isempty(s)
	return s == nil or s == ""
end

dap.adapters.python = {
	type = "executable",
	command = "/usr/bin/python",
	args = { "-m", "debugpy.adapter" },
}
dap.configurations.python = {
	{
		-- The first three options are required by nvim-dap
		type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
		request = "launch",
		name = "Launch file",
		-- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

		program = "${file}", -- This configuration will launch the current file if used.
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
