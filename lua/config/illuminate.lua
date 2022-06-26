local status, _ = pcall(require, "vim-illuminate")
if not status then
	return
end

-- illuminate setting
vim.api.nvim_command([[ hi def link LspReferenceText CursorLine ]])
vim.api.nvim_command([[ hi def link LspReferenceWrite CursorLine ]])
vim.api.nvim_command([[ hi def link LspReferenceRead CursorLine ]])
vim.g.Illuminate_delay = 3000
-- Don't highlight word under cursor (default: 1)
vim.g.Illuminate_highlightUnderCursor = 0
vim.g.Illuminate_ftblacklist = { "alpha", "NvimTree" }
vim.g.Illuminate_ftwhitelist = { "python" }
