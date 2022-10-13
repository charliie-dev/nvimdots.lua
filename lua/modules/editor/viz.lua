local keymap = vim.keymap.set

-- to start off from normal mode
keymap("n", "vv", "<cmd>lua require('vi-viz').vizInit()<cr>", { noremap = true })
-- expand and contract
keymap("x", "=", "<cmd>lua require('vi-viz').vizExpand()<cr>", { noremap = true })
keymap("x", "-", "<cmd>lua require('vi-viz').vizContract()<cr>", { noremap = true })
-- nice to have to insert before and after
keymap("x", "ii", "<cmd>lua require('vi-viz').vizInsert()<cr>", { noremap = true })
keymap("x", "aa", "<cmd>lua require('vi-viz').vizAppend()<cr>", { noremap = true })
