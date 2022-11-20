vim.api.nvim_set_hl(0, "Headline1", { fg = "#8bc56f", bg = "#1b2816" })
vim.api.nvim_set_hl(0, "Headline2", { fg = "#1db8c4", bg = "#20262e" })
vim.api.nvim_set_hl(0, "CodeBlock", { bg = "#1c1c1c" })
vim.api.nvim_set_hl(0, "Dash", { bg = "#D19A66", bold = true })

require("headlines").setup({
	markdown = {
		headline_highlights = { "Headline1", "Headline2" },
		codeblock_highlight = "CodeBlock",
		dash_highlight = "Dash",
		dash_string = "-",
		quote_highlight = "Quote",
		quote_string = "┃",
		fat_headlines = true,
		fat_headline_upper_string = "▃",
		fat_headline_lower_string = "▀",
	},
	rmd = {
		treesitter_language = "markdown",
		headline_highlights = { "Headline1", "Headline2" },
		codeblock_highlight = "CodeBlock",
		dash_highlight = "Dash",
		dash_string = "-",
		quote_highlight = "Quote",
		quote_string = "┃",
		fat_headlines = true,
		fat_headline_upper_string = "▃",
		fat_headline_lower_string = "▀",
	},
	norg = {
		headline_highlights = { "Headline1", "Headline2" },
		codeblock_highlight = "CodeBlock",
		dash_highlight = "Dash",
		dash_string = "-",
		doubledash_highlight = "DoubleDash",
		doubledash_string = "=",
		quote_highlight = "Quote",
		quote_string = "┃",
		fat_headlines = true,
		fat_headline_upper_string = "▃",
		fat_headline_lower_string = "▀",
	},
	org = {
		headline_highlights = { "Headline1", "Headline2" },
		codeblock_highlight = "CodeBlock",
		dash_highlight = "Dash",
		dash_string = "-",
		quote_highlight = "Quote",
		quote_string = "┃",
		fat_headlines = true,
		fat_headline_upper_string = "▃",
		fat_headline_lower_string = "▀",
	},
})
