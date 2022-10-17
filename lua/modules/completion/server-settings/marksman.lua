-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/marksman.lua
return {
	cmd = { "marksman", "server" },
	filetypes = { "markdown" },
	single_file_support = false,
}
