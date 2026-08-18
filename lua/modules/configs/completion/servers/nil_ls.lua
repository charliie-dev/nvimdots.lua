-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/nil_ls.lua
return {
	on_init = function(client, _)
		if client.server_capabilities then
			client.server_capabilities.semanticTokensProvider = nil
			client.server_capabilities.completionProvider = nil
		end
	end,
	settings = {
		["nil"] = {
			testSetting = 42,
			nix = { flake = { autoArchive = false } },
		},
	},
}
