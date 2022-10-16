vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
vim.api.nvim_set_hl(0, "LeapMatch", {
	fg = "white", -- for light themes, set to 'black' or similar
	bold = true,
	nocombine = true,
})
require("leap").opts.highlight_unlabeled_phase_one_targets = true

require("leap").add_default_mappings()
