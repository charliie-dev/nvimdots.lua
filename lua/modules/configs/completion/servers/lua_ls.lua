-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/lua_ls.lua
return {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = {
				-- rex: Rex 的 init.lua 與 rex do 腳本的全域 API
				globals = { "vim", "rex" },
				disable = { "different-requires", "undefined-field" },
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.fn.expand("$VIMRUNTIME/lua"),
					vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
				},
				maxPreload = 100000,
				preloadFileSize = 10000,
			},
			hint = { enable = true, setType = true },
			format = { enable = false },
			-- Do not override treesitter lua highlighting with lua_ls's highlighting
			semantic = { enable = false },
		},
	},
}
