-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/neocmake.lua
local util = require("lspconfig.util")
return {
	cmd = { "neocmakelsp", "--stdio" },
	filetypes = { "cmake" },
	root_dir = function(fname)
		return util.root_pattern(unpack({ ".git", "build", "cmake" }))(fname)
	end,
	single_file_support = true,
}
