-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/harper_ls.lua
return {
	filetypes = { "markdown", "text", "gitcommit" },
	settings = {
		["harper-ls"] = {
			linters = {
				spell_check = true,
				spelled_numbers = false,
				an_a = true,
				sentence_capitalization = false,
				unclosed_quotes = true,
				wrong_quotes = false,
				long_sentences = true,
				repeated_words = true,
				spaces = true,
				matcher = true,
				correct_number_suffix = true,
				number_suffix_capitalization = true,
				multiple_sequential_pronouns = true,
			},
		},
	},
}
