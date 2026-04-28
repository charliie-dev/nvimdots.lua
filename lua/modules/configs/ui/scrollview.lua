return function()
	local icons = { diagnostics = require("modules.utils.icons").get("diagnostics", true) }

	require("modules.utils").load_plugin("scrollview", {
		mode = "auto",
		winblend_gui = 0,
		signs_on_startup = { "diagnostics", "folds", "marks", "search" },
		diagnostics_error_symbol = icons.diagnostics.Error,
		diagnostics_warn_symbol = icons.diagnostics.Warning,
		diagnostics_info_symbol = icons.diagnostics.Information,
		diagnostics_hint_symbol = icons.diagnostics.Hint,
		excluded_filetypes = {
			"snacks_dashboard",
			"fugitive",
			"git",
			"notify",
			"snacks_notif",
			"oil",
			"terminal",
			"snacks_terminal",
			"undotree",
		},
	})
end
