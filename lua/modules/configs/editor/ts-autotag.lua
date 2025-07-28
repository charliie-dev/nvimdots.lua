return function()
	require("modules.utils").load_plugin("nvim-ts-autotag", {
		opts = {
			-- Defaults
			enable_close = true,
			enable_rename = true,
			enable_close_on_slash = false,
		},
		-- Also override individual filetype configs, these take priority.
		-- Empty by default, useful if one of the "opts" global settings
		-- doesn't work well in a specific filetype
		per_filetype = {
			["html"] = {
				enable_close = true,
			},
		},
	})
end
