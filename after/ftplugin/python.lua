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

-- Remove only native shadows of global Treesitter motions, not user ftplugin mappings.
for _, mode in ipairs({ "n", "x", "o" }) do
	for _, lhs in ipairs({ "][", "]]", "[[", "[]", "]m", "]M", "[m", "[M" }) do
		local mapping = vim.fn.maparg(lhs, mode, false, true)
		local script = mapping.buffer == 1 and mapping.sid > 0 and vim.fn.getscriptinfo({ sid = mapping.sid })[1]
		if script and script.name == vim.env.VIMRUNTIME .. "/ftplugin/python.vim" then
			vim.keymap.del(mode, lhs, { buffer = true })
		end
	end
end
