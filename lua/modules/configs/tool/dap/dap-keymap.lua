local M = {}

local did_load_debug_mappings = false

function M.load_extras()
	if not did_load_debug_mappings then
		require("modules.utils.keymap").amend(
			"Debugging",
			"_debugging",
			{ "n", "v" },
			"K",
			"<Cmd>lua require('dapui').eval()<CR>",
			{ nowait = true, desc = "Evaluate expression under cursor" }
		)
		did_load_debug_mappings = true
	end
end

return M
