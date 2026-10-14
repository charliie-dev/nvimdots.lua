return function()
	require("modules.utils").load_plugin("smart-splits", {
		resize = {
			-- The default number of lines/columns to resize by at a time
			amount = 3,
		},
		ignored_buftypes = {
			"nofile",
			"quickfix",
			"prompt",
		},
		ignored_filetypes = { "oil" },
	})
end
