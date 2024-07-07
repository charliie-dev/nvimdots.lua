return function()
	require("headlines").setup({
		markdown = {
			codeblock_highlight = "CodeBlock",
			dash_highlight = "Dash",
			dash_string = "-",
			quote_highlight = "Quote",
			quote_string = "┃",
			fat_headlines = false,
			fat_headline_upper_string = "▃",
			fat_headline_lower_string = "▀",
			headline_highlights = {
				"Headline1",
				"Headline2",
				"Headline3",
				"Headline4",
				"Headline5",
				"Headline6",
			},

			bullets = { "󰎤", "󰎧", "󰎪", "󰎭", "󰎱", "󰎳" },
		},
	})
end
