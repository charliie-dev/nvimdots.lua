require("luasnip").config.set_config({
	history = true,
	updateevents = "TextChanged,TextChangedI",
	delete_check_events = "TextChanged,InsertLeave",
})

require("luasnip.loaders.from_lua").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load({
	paths = { "./snippets/" },
})
