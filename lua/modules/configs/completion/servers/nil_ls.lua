-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/nil_ls.lua
return {
	cmd = { "nil" },
	filetypes = { "nix" },
	single_file_support = true,
	autostart = true,
	settings = {
		["nil"] = {
			testSetting = 42,
			nix = { flake = { autoArchive = true } },
		},
	},
}
