-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/harper_ls.lua
return {
	filetypes = { "markdown", "text", "gitcommit" },
	settings = {
		["harper-ls"] = {
			linters = {
				SpellCheck = true,
				SpelledNumbers = false,
				AnA = true,
				SentenceCapitalization = false,
				UnclosedQuotes = true,
				LongSentences = true,
				RepeatedWords = true,
				Spaces = true,
				CorrectNumberSuffix = true,
				NumberSuffixCapitalization = true,
				MultipleSequentialPronouns = true,
			},
		},
	},
}
