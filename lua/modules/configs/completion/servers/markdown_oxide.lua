-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/markdown_oxide.lua
return {
	root_dir = function(fname, _)
		return require("lspconfig").util.root_pattern(".git", ".obsidian", ".moxide.toml")(fname)
	end,
	filetypes = { "markdown" },
	single_file_support = true,
	cmd = { "markdown-oxide" },
}
