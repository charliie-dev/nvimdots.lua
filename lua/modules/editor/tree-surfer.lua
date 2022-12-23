local icons = {
	ts = require("modules.ui.icons").get("ts"),
}

require("syntax-tree-surfer").setup({
	highlight_group = "STS_highlight",
	disable_no_instance_found_report = false,
	default_desired_types = {
		"function",
		"arrow_function",
		"function_definition",
		"if_statement",
		"else_clause",
		"else_statement",
		"elseif_statement",
		"for_statement",
		"while_statement",
		"switch_statement",
	},
	left_hand_side = "fdsawervcxqtzb",
	right_hand_side = "jkl;oiu.,mpy/n",
	icon_dictionary = {
		["if_statement"] = icons.ts.IF,
		["else_clause"] = icons.ts.ELSE,
		["else_statement"] = icons.ts.ELSE,
		["elseif_statement"] = icons.ts.ELSE,
		["for_statement"] = icons.ts.FOR,
		["while_statement"] = icons.ts.WHILE,
		["switch_statement"] = icons.ts.SWITCH,
		["function"] = icons.ts.FUNC,
		["function_definition"] = icons.ts.FUNC,
		["variable_declaration"] = icons.ts.VAR,
	},
})

-- Targeted Jump with virtual_text
local sts = require("syntax-tree-surfer")
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true, nowait = true }
keymap("n", "gv", function() -- only jump to variable_declarations, can only jump within visible window
	sts.targeted_jump({ "variable_declaration" })
end, opts)
keymap("n", "gfu", function() -- only jump to functions
	sts.targeted_jump({ "function", "arrrow_function", "function_definition" })
	--> In this example, the Lua language schema uses "function",
	--  when the Python language uses "function_definition"
	--  we include both, so this keymap will work on both languages
end, opts)
keymap("n", "gif", function() -- only jump to if_statements
	sts.targeted_jump({ "if_statement" })
end, opts)
keymap("n", "gfo", function() -- only jump to for_statements
	sts.targeted_jump({ "for_statement" })
end, opts)
keymap("n", "gj", function() -- jump to all that you specify
	sts.targeted_jump({
		"function",
		"if_statement",
		"else_clause",
		"else_statement",
		"elseif_statement",
		"for_statement",
		"while_statement",
		"switch_statement",
	})
end, opts)
