return function()
	local icons = {
		diagnostics = require("modules.utils.icons").get("diagnostics"),
		ui = require("modules.utils.icons").get("ui"),
	}

	require("modules.utils").load_plugin("snacks", {
		bigfile = { enabled = true },
		bufdelete = { enabled = true },
		notifier = {
			enabled = true,
			timeout = 2000,
			icons = {
				error = icons.diagnostics.Error,
				warn = icons.diagnostics.Warning,
				info = icons.diagnostics.Information,
				debug = icons.ui.Bug,
				trace = icons.ui.Pencil,
			},
			style = "compact",
		},
		scroll = {
			enabled = true,
			animate = {
				duration = { step = 15, total = 150 },
			},
		},
		-- Disable all other modules explicitly
		animate = { enabled = false },
		dashboard = { enabled = false },
		dim = { enabled = false },
		explorer = { enabled = false },
		indent = { enabled = false },
		input = { enabled = false },
		lazygit = { enabled = false },
		picker = { enabled = false },
		quickfile = { enabled = false },
		scope = { enabled = false },
		statuscolumn = { enabled = false },
		terminal = { enabled = false },
		toggle = { enabled = false },
		words = { enabled = false },
		zen = { enabled = false },
	})
end
