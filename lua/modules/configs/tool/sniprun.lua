return function()
	require("modules.utils").load_plugin("sniprun", {
		borders = "single",
		inline_messages = 0,
		interpreter_options = {},
		display = {
			"Classic", -- "display results in the command-line area
			-- Ok and error results as virtual text (multiline is shortened). Not "VirtualTextOk" plus
			-- "VirtualTextErr": sniprun sorts the modes and the error pass clears an OK result's text.
			"VirtualText",
			-- "TempFloatingWindow", -- "display results in a floating window
			"LongTempFloatingWindow", -- "same as above, but only long results. To use with VirtualText
			-- "Terminal"                 -- "display results in a vertical split
		},
	})
end
