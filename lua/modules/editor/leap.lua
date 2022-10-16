require("leap").setup({
	max_phase_one_targets = nil,
	highlight_unlabeled_phase_one_targets = false,
	max_highlighted_traversal_targets = 10,
	case_sensitive = false,
	-- Sets of characters that should match each other.
	-- Obvious candidates are braces and quotes ('([{', ')]}', '`"\'').
	equivalence_classes = { " \t\r\n" },
	substitute_chars = {},
	-- Leaving the appropriate list empty effectively disables "smart" mode,
	-- and forces auto-jump to be on or off.
	-- safe_labels = { . . . },
	-- labels = { . . . },
	special_keys = {
		repeat_search = "<enter>",
		next_phase_one_target = "<enter>",
		next_target = { "<enter>", ";" },
		prev_target = { "<tab>", "," },
		next_group = "<space>",
		prev_group = "<tab>",
		multi_accept = "<enter>",
		multi_revert = "<backspace>",
	},
})
