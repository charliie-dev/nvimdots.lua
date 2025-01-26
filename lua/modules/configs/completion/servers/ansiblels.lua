-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/ansiblels.lua
local util = require("lspconfig.util")
return {
	cmd = { "ansible-language-server", "--stdio" },
	settings = {
		ansible = {
			python = {
				interpreterPath = "python",
			},
			ansible = {
				path = "ansible",
			},
			executionEnvironment = {
				enabled = false,
			},
			validation = {
				enabled = true,
				lint = {
					enabled = true,
					path = "ansible-lint",
				},
			},
		},
	},
	filetypes = { "yaml.ansible" },
	root_dir = util.root_pattern("ansible.cfg", ".ansible-lint"),
	single_file_support = true,
}
