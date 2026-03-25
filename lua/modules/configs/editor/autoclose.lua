return function()
	require("modules.utils").load_plugin("autoclose", {
		keys = {
			["("] = { escape = false, close = true, pair = "()" },
			["["] = { escape = false, close = true, pair = "[]" },
			["{"] = { escape = false, close = true, pair = "{}" },

			["<"] = { escape = true, close = true, pair = "<>", enabled_filetypes = { "rust" } },
			[">"] = { escape = true, close = false, pair = "<>" },
			[")"] = { escape = true, close = false, pair = "()" },
			["]"] = { escape = true, close = false, pair = "[]" },
			["}"] = { escape = true, close = false, pair = "{}" },

			['"'] = { escape = true, close = true, pair = '""' },
			["`"] = { escape = true, close = true, pair = "``" },
			["'"] = { escape = true, close = true, pair = "''", disabled_filetypes = { "rust" } },
		},
		options = {
			disable_when_touch = false,
			disabled_filetypes = {
				"checkhealth",
				"dap-repl",
				"diff",
				"help",
				"log",
				"notify",
				"oil",
				"Outline",
				"qf",
				"snacks_dashboard",
				"snacks_terminal",
				"undotree",
				"vimwiki",
			},
		},
	})
end
