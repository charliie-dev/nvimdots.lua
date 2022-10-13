require("gomove").setup({
	-- whether or not to map default key bindings, (true/false)
	map_defaults = false,
	-- whether or not to reindent lines moved vertically (true/false)
	reindent = true,
	-- whether or not to undojoin same direction moves (true/false)
	undojoin = true,
	-- whether to not to move past end column when moving blocks horizontally, (true/false)
	move_past_end_col = false,
})

local keymap = vim.keymap.set
keymap("n", "<leader><S-h>", "<Plug>GoNSMLeft", {})
keymap("n", "<leader><S-j>", "<Plug>GoNSMDown", {})
keymap("n", "<leader><S-k>", "<Plug>GoNSMUp", {})
keymap("n", "<leader><S-l>", "<Plug>GoNSMRight", {})

keymap("x", "<leader><S-h>", "<Plug>GoVSMLeft", {})
keymap("x", "<leader><S-j>", "<Plug>GoVSMDown", {})
keymap("x", "<leader><S-k>", "<Plug>GoVSMUp", {})
keymap("x", "<leader><S-l>", "<Plug>GoVSMRight", {})
