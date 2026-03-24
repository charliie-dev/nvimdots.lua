return function()
	require("modules.utils").load_plugin("oil", {
		default_file_explorer = true,
		columns = { "icon" },
		delete_to_trash = true,
		skip_confirm_for_simple_edits = true,
		watch_for_changes = true,
		lsp_file_methods = {
			enabled = true,
			timeout_ms = 1000,
			autosave_changes = "unmodified",
		},
		constrain_cursor = "editable",
		view_options = {
			show_hidden = true,
			natural_order = "fast",
		},
		keymaps = {
			["g?"] = { "actions.show_help", mode = "n" },
			["<CR>"] = "actions.select",
			["<C-v>"] = { "actions.select", opts = { vertical = true } },
			["<C-s>"] = { "actions.select", opts = { horizontal = true } },
			["<C-t>"] = { "actions.select", opts = { tab = true } },
			["<C-p>"] = "actions.preview",
			["q"] = { "actions.close", mode = "n" },
			["<C-l>"] = "actions.refresh",
			["-"] = { "actions.parent", mode = "n" },
			["_"] = { "actions.open_cwd", mode = "n" },
			["`"] = { "actions.cd", mode = "n" },
			["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
			["gs"] = { "actions.change_sort", mode = "n" },
			["gx"] = "actions.open_external",
			["g."] = { "actions.toggle_hidden", mode = "n" },
			["g\\"] = { "actions.toggle_trash", mode = "n" },
		},
	})
end
