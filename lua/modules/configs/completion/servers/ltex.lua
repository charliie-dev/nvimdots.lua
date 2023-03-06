-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/ltex.lua
-- https://gist.github.com/lbiaggi/a3eb761ac2fdbff774b29c88844355b8

return function(options)
	require("lspconfig").ltex.setup({
		on_attach = function()
			require("lsp_signature").on_attach({
				bind = true,
				use_lspsaga = false,
				floating_window = true,
				fix_pos = true,
				hint_enable = true,
				hi_parameter = "Search",
				handler_opts = {
					border = "rounded",
				},
			})
			require("ltex_extra").setup({
				load_langs = { "en-US" },
				init_check = true,
				path = "./spell",
				log_level = "error",
			})
		end,
		capabilities = options.capabilities,
		single_file_support = true,
		settings = {
			ltex = { language = "en-US" },
		},
	})
end
