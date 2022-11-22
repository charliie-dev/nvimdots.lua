require("neogen").setup({
	snippet_engine = "luasnip",
	enabled = true,
	languages = {
		lua = {
			template = {
				annotation_convention = "emmylua",
			},
		},
		python = {
			template = {
				annotation_convention = "google_docstrings",
			},
		},
		rust = {
			template = {
				annotation_convention = "rustdoc",
			},
		},
		javascript = {
			template = {
				annotation_convention = "jsdoc",
			},
		},
		typescript = {
			template = {
				annotation_convention = "tsdoc",
			},
		},
		typescriptreact = {
			template = {
				annotation_convention = "tsdoc",
			},
		},
	},
})

-- INFO: Currently supported languages: https://github.com/danymat/neogen#supported-languages

-- :Neogen func|class|type|file
