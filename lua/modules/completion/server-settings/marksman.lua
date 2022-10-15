-- https://github.com/artempyanykh/marksman
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#marksman
return {
	cmd = { "marksman", "server" },
	filetypes = { "markdown" },
	single_file_support = false,
}
