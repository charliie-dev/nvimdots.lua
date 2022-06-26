local status, glow = pcall(require, "glow")
if not status then
	return
end

vim.g.glow_binary_path = vim.env.HOME .. "/.local/bin"

vim.g.glow_border = "rounded"

vim.g.glow_width = 120

vim.g.glow_use_pager = true

vim.g.glow_style = "dark"

-- Usage:
-- :Glow [path-to-md-file] to view the md file.
-- `Ctrl-w + |` set window's width max.
-- `Ctrl-w + _` set window's height max
