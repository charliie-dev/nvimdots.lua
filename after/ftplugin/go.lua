local set = vim.opt_local

set.commentstring = "//%s"
set.expandtab = false
set.shiftwidth = 4
set.softtabstop = 4
set.tabstop = 4

-- Expose the configured global Treesitter motions (including user overrides).
for _, mode in ipairs({ "n", "x", "o" }) do
	for _, lhs in ipairs({ "][", "]]", "[[", "[]" }) do
		pcall(vim.keymap.del, mode, lhs, { buffer = true })
	end
end
