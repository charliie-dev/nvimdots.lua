-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/nil_ls.lua
local util = require("lspconfig.util")
return {
	cmd = { "nil" },
	filetypes = { "nix" },
	single_file_support = true,
	root_dir = util.root_pattern("flake.nix", ".git"),
	settings = {
		["nil"] = {
			testSetting = 42,
			nix = { flake = { autoArchive = true } },
		},
	},
}
