-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/tombi.lua
return {
	on_init = function(client, _)
		if client.server_capabilities then
			client.server_capabilities.semanticTokensProvider = nil
		end
	end,
}
