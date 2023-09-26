-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/lua_ls.lua

return {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
				disable = { "different-requires" },
			},
			hint = { enable = true, setType = true },
			format = { enable = false },
			telemetry = { enable = false },
			-- Do not override treesitter lua highlighting with lua_ls's highlighting
			semantic = { enable = false },
		},
	},
}
