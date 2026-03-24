return function()
	require("modules.utils").load_plugin("neoscroll", {
		hide_cursor = true,
		stop_eof = true,
		respect_scrolloff = false,
		cursor_scrolls_alone = true,
		easing = "linear",
		mappings = {
			"<C-u>",
			"<C-d>",
			"<C-b>",
			"<C-f>",
			"<C-y>",
			"<C-e>",
			"zt",
			"zz",
			"zb",
		},
	})
end
