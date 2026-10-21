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
				ignore = {
					-- disable: line too long (formatter handles line length)
					"E501",
				},
			},
			-- the same line length as black
			lineLength = 88,
			configurationPreference = "filesystemFirst",
		},
	},
}
