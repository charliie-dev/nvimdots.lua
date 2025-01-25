-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/marksman.lua
return {
	cmd = { "marksman", "server" },
	filetypes = { "markdown" },
	single_file_support = false,
}
