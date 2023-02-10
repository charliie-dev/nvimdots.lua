return function()
	local leap = require("leap")
	leap.opts.max_phase_one_targets = nil
	leap.opts.highlight_unlabeled_phase_one_targets = false
	leap.opts.case_sensitive = false
	leap.opts.special_keys = {
		repeat_search = "<tab>",
		next_phase_one_target = "<tab>",
		next_target = { "<tab>", ";" },
		prev_target = { "<S-tab>", "," },
		next_group = "<space>",
		prev_group = "<S-space>",
		multi_accept = "<enter>",
		multi_revert = "<backspace>",
	}
end
