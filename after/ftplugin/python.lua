local set = vim.opt_local

set.autoindent = true
set.cindent = true
set.copyindent = true
set.expandtab = true
set.smartindent = true
set.shiftwidth = 4
set.smarttab = true
set.softtabstop = 4
set.tabstop = 8

-- Expose the configured global Treesitter motions (including user overrides).
for _, mode in ipairs({ "n", "x", "o" }) do
	for _, lhs in ipairs({ "][", "]]", "[[", "[]", "]m", "]M", "[m", "[M" }) do
		pcall(vim.keymap.del, mode, lhs, { buffer = true })
	end
end
