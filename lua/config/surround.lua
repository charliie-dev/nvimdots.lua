local status, surround = pcall(require, "surround")
if not status then
	return
end

surround.setup({
	context_offset = 100,
	load_autogroups = false,
	mappings_style = "sandwich",
	space_on_closing_char = false,
	map_insert_mode = true,
	quotes = { "'", '"' },
	brackets = { "(", "{", "[" },
	pairs = {
		nestable = { { "(", ")" }, { "[", "]" }, { "{", "}" } },
		linear = { { "'", "'" }, { "`", "`" }, { '"', '"' } },
	},
	prefix = "s",
})
