return function()
	require("modules.utils").load_plugin("smear_cursor", {
		trailing_stiffness = 0.5,
		distance_stop_animating = 0.3,
		-- hide_target_hack = false, -- true     boolean
		legacy_computing_symbols_support = true, -- Transparent background
		-- filetypes_disabled = {},
	})
end
