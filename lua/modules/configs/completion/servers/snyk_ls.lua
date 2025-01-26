-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/snyk_ls.lua
local util = require("lspconfig.util")
return {
	cmd = { "snyk-ls" },
	root_dir = util.root_pattern(".git", ".snyk"),
	filetypes = {
		"go",
		"gomod",
		"javascript",
		"typescript",
		"json",
		"python",
		"requirements",
		"helm",
		"yaml",
		"terraform",
		"terraform-vars",
	},
	single_file_support = true,
	settings = {},
	-- Configuration from https://github.com/snyk/snyk-ls#configuration-1
	init_options = {
		activateSnykCode = "true",
	},
}
