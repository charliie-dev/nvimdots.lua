-- nnoremap <leader>p :lua require("nabla").popup()<CR> "
-- Customize with popup({border = ...})  : `single` (default), `double`, `rounded`
vim.keymap.set("n", "<leader>mp", "<cmd>lua require('nabla').popup()<cr>", { noremap = true, nowait = true })
