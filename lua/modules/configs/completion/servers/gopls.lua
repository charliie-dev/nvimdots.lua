-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/gopls.lua
return {
	settings = {
		gopls = {
			-- gopls sends empty semantic tokens unless this is on. nvim-lspconfig turns it on too; keep the
			-- choice here so it survives a change of that default.
			semanticTokens = true,
		},
	},
}
