require("sidebar-nvim").setup({
	disable_default_keybindings = 0,
	bindings = {
		["q"] = function()
			require("sidebar-nvim").close()
		end,
	},
	open = false,
	side = "right",
	initial_width = 35,
	hide_statusline = true,
	update_interval = 1000,
	sections = { "datetime", "diagnostics", "git" },
	section_separator = { "", "-----", "" },
	section_title_separator = { "" },
	containers = {
		attach_shell = "/usr/bin/bash",
		show_all = true,
		interval = 5000,
	},
	datetime = { format = "%a %b %d, %H:%M", clocks = { { name = "local" } } },
	todos = { ignored_paths = { "~" } },
})
