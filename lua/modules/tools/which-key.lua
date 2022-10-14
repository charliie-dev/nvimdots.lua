local icon = require("modules.ui.icons")

require("which-key").setup({
	plugins = {
		presets = {
			operators = false,
			motions = false,
			text_objects = false,
			windows = false,
			nav = false,
			z = true,
			g = true,
		},
	},

	icons = {
		breadcrumb = icon.ui.Separator,
		separator = icon.misc.Vbar,
		group = "+",
	},

	window = {
		border = "none",
		position = "bottom",
		margin = { 1, 0, 1, 0 },
		padding = { 1, 1, 1, 1 },
		winblend = 0,
	},
})
