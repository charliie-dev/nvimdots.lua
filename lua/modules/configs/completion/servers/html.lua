-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/html.lua
local util = require("lspconfig.util")
return {
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = { "html", "templ" },
	root_dir = util.root_pattern("package.json", ".git"),
	single_file_support = true,
	settings = {},
	init_options = {
		provideFormatter = true,
		embeddedLanguages = { css = true, javascript = true },
		configurationSection = { "html", "css", "javascript" },
	},
}
