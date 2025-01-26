-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/taplo.lua
return {
	cmd = { "taplo", "lsp", "stdio" },
	filetypes = { "toml" },
	root_dir = function(fname)
		return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
	end,
	single_file_support = true,
}
