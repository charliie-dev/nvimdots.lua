return function()
	require("modules.utils").load_plugin("nvim-ts-autotag", {
		filetypes = {
			"glimmer",
			"handlebars",
			"hbs",
			"html",
			"javascript",
			"javascriptreact",
			"jsx",
			"markdown",
			"php",
			"rescript",
			"svelte",
			"tsx",
			"typescript",
			"typescriptreact",
			"vue",
			"xml",
		},
		skip_tags = {},
	})
end
