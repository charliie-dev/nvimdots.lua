-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/jsonls.lua
return {
	flags = { debounce_text_changes = 500 },
	settings = {
		json = {
			validate = { enable = true },
			format = { enable = true },
			hover = true,
			schemaDownload = { enable = true },
			schemas = require("schemastore").json.schemas(),
		},
	},
}
