require("sidebar-nvim").setup({
	disable_default_keybindings = 0,
	bindings = {
		["q"] = function()
			require("sidebar-nvim").close()
		end,
	},
	open = false,
	side = "right",
	initial_width = 30,
	hide_statusline = true,
	update_interval = 1000,
	sections = {
		"git",
		"diagnostics",
		"todos",
		"symbols",
	},
	section_separator = { "", "-----", "" },
	section_title_separator = { "" },
	containers = {
		attach_shell = "/usr/bin/bash",
		show_all = true,
		interval = 5000,
	},
	todos = { ignored_paths = { "~" } },
})

vim.keymap.set("n", "sb", "<cmd>lua require('sidebar-nvim').toggle()<cr>", { noremap = true })
