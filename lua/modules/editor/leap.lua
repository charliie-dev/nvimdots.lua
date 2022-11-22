vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
vim.api.nvim_set_hl(0, "LeapMatch", {
	fg = "white", -- for light themes, set to 'black' or similar
	bold = true,
	nocombine = true,
})
require("leap").opts.highlight_unlabeled_phase_one_targets = true

-- vim.keymap.set("n", "s", "<Nop>", { noremap = false })
-- vim.keymap.set("n", "S", "<Nop>", { noremap = false })
require("leap").add_default_mappings()
