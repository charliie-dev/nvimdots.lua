-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/nil_ls.lua
return {
	single_file_support = true,
	settings = {
		["nil"] = {
			testSetting = 42,
			nix = { flake = { autoArchive = true } },
		},
	},
}
