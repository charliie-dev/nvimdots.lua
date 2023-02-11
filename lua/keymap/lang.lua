local bind = require("keymap.bind")
local map_cr = bind.map_cr
-- local map_cu = bind.map_cu
-- local map_cmd = bind.map_cmd

local plug_map = {
	--- markdowny.nvim(hard-coded)
	-- vim.keymap.set("v", "<C-b>", ":lua require('markdowny').bold()<cr>", { buffer = 0 })
	-- vim.keymap.set("v", "<C-i>", ":lua require('markdowny').italic()<cr>", { buffer = 0 })
	-- vim.keymap.set("v", "<C-k>", ":lua require('markdowny').link()<cr>", { buffer = 0 })

	-- Plugin markdown-preview
	["n|<F12>"] = map_cr("MarkdownPreviewToggle"):with_noremap():with_silent():with_desc("tool: Preview markdown"),
}

bind.nvim_load_mapping(plug_map)
