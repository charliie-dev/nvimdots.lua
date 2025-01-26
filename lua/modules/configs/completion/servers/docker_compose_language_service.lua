-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/docker_compose_language_service.lua
local util = require("lspconfig.util")
return {
	cmd = { "docker-compose-langserver", "--stdio" },
	filetypes = { "yaml.docker-compose" },
	root_dir = util.root_pattern("docker-compose.yaml", "docker-compose.yml", "compose.yaml", "compose.yml"),
	single_file_support = true,
}
