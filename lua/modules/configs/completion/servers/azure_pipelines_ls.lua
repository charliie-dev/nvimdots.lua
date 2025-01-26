-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/azure_pipelines_ls.lua
local util = require("lspconfig.util")
return {
	cmd = { "azure-pipelines-language-server", "--stdio" },
	filetypes = { "yaml" },
	root_dir = util.root_pattern("azure-pipelines.yml"),
	single_file_support = true,
	settings = {},
}
