-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/taplo.lua
return {
	single_file_support = true,
	on_init = function(client, _)
		if client.server_capabilities then
			client.server_capabilities.semanticTokensProvider = nil
		end
	end,
}
