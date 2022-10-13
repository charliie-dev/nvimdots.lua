require("osc52").setup({
	max_length = 0, -- Maximum length of selection (0 for no limit)
	silent = true, -- Disable message on successful copy
	trim = false, -- Trim text before copy
})

--- nvim-osc52 keymap
local keymap = vim.keymap.set
-- In normal mode, <leader>c is an operator that will copy the given text to the clipboard.
vim.keymap.set("n", "<leader>c", require("osc52").copy_operator, { expr = true })
-- In normal mode, <leader>cc will copy the current line.
vim.keymap.set("n", "<leader>cc", "<leader>c_", { remap = true })
-- In visual mode, <leader>c will copy the current selection.
vim.keymap.set("x", "<leader>c", require("osc52").copy_visual)
