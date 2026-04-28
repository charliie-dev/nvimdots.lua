return function()
	require("modules.utils").load_plugin("tiny-inline-diagnostic", {
		preset = "modern",
		transparent_bg = false,
		transparent_cursorline = true,
		options = {
			show_source = {
				enabled = true,
				if_many = true,
			},
			show_code = true,
			add_messages = {
				messages = true,
				display_count = true,
				use_max_severity = false,
				show_multiple_glyphs = true,
			},
			set_arrow_to_diag_color = false,
			use_icons_from_diagnostic = true,
			show_all_diags_on_cursorline = true,
			show_related = {
				enabled = true,
				max_count = 3,
			},
			enable_on_insert = false,
			multilines = {
				enabled = true,
				always_show = true,
			},
			break_line = {
				enabled = true,
				after = 60,
			},
			overflow = {
				mode = "wrap",
				padding = 0,
			},
			-- Filter severities up to the diagnostics level setting
			severity = vim.tbl_filter(function(level)
				return level <= vim.diagnostic.severity[require("core.settings").diagnostics_level]
			end, {
				vim.diagnostic.severity.ERROR,
				vim.diagnostic.severity.WARN,
				vim.diagnostic.severity.INFO,
				vim.diagnostic.severity.HINT,
			}),
		},
		disabled_ft = {
			"snacks_dashboard",
			"checkhealth",
			"dap-repl",
			"diff",
			"help",
			"log",
			"notify",
			"snacks_notif",
			"oil",
			"Outline",
			"qf",
			"terminal",
			"snacks_terminal",
			"undotree",
			"vimwiki",
		},
	})

	-- After setup, turn inline diagnostics on or off based on the `diagnostics_virtual_lines` setting
	require("tiny-inline-diagnostic")[require("core.settings").diagnostics_virtual_lines and "enable" or "disable"]()
end
