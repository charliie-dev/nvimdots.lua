-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/marksman.lua
local util = require("lspconfig.util")
return {
	cmd = { "marksman", "server" },
	filetypes = { "markdown", "markdown.mdx" },
	root_dir = function(fname)
		local root_files = { ".marksman.toml" }
		return util.root_pattern(unpack(root_files))(fname)
			or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
	end,
	single_file_support = true,
}
