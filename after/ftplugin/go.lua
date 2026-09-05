local set = vim.opt_local

set.commentstring = "//%s"
set.expandtab = false
set.shiftwidth = 4
set.softtabstop = 4
set.tabstop = 4

-- Remove only native shadows of global Treesitter motions, not user ftplugin mappings.
for _, mode in ipairs({ "n", "x", "o" }) do
	for _, lhs in ipairs({ "][", "]]", "[[", "[]" }) do
		local mapping = vim.fn.maparg(lhs, mode, false, true)
		local script = mapping.buffer == 1 and mapping.sid > 0 and vim.fn.getscriptinfo({ sid = mapping.sid })[1]
		if script and script.name == vim.env.VIMRUNTIME .. "/ftplugin/go.vim" then
			vim.keymap.del(mode, lhs, { buffer = true })
		end
	end
end
