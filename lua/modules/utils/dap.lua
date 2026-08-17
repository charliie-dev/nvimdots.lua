local function input_args()
	return function()
		local argument_string = vim.fn.input("Program arg(s) (enter nothing to leave it null): ")
		return vim.fn.split(argument_string, " ", true)
	end
end

local function input_exec_path()
	return function()
		return vim.fn.input('Path to executable (default to "a.out"): ', vim.fn.expand("%:p:h") .. "/a.out", "file")
	end
end

return {
	input_args = input_args,
	input_exec_path = input_exec_path,
}
