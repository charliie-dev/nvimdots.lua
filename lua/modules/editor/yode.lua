require("yode-nvim").setup({})

-- local keymap = vim.keymap.set
-- local opts = { noremap = true, nowait = true }

-- TODO: keymaps somehow not working, just use commands instead.
-- -- focus on a code part and make it floating, stay at the current (main) view
-- keymap("", "nr", "<cmd>YodeCreateSeditorFloating<cr>", opts)
-- keymap("v", "nr", "<cmd>YodeCreateSeditorFloating<cr>", opts)
-- -- delete the current buffer and jump back to file, if it is a seditor
-- keymap("n", "<leader>bd", "<cmd>YodeBufferDelete<cr>", opts)
-- keymap("i", "<leader>bd", "<esc><cmd>YodeBufferDelete<cr>", opts)
-- -- these commands fall back to overwritten keys when cursor is in split window
-- keymap("", "<C-W>j", "<cmd>YodeLayoutShiftWinDown<cr>", opts)
-- keymap("", "<C-W>k", "<cmd>YodeLayoutShiftWinUp<cr>", opts)
-- keymap("", "<C-W>J", "<cmd>YodeLayoutShiftWinBottom<cr>", opts)
-- keymap("", "<C-W>K", "<cmd>YodeLayoutShiftWinTop<cr>", opts)
