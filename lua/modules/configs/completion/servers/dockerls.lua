-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/dockerls.lua
local util = require("lspconfig.util")

return {
	cmd = { "docker-langserver", "--stdio" },
	filetypes = { "dockerfile" },
	root_dir = util.root_pattern("Dockerfile"),
	single_file_support = true,
}
