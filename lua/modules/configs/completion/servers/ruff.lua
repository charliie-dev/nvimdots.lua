-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/ruff.lua
return {
	init_options = {
		settings = {
			lint = {
				select = {
					-- enable: pycodestyle
					"E",
					-- enable: pyflakes
					"F",
				},
				extendSelect = {
					-- enable: isort
					"I",
				},
			},
			-- the same line length as black
			lineLength = 88,
			configurationPreference = "filesystemFirst",
		},
	},
}
