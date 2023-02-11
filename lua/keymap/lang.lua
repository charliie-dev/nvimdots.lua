local bind = require("keymap.bind")
local map_cr = bind.map_cr
-- local map_cu = bind.map_cu
-- local map_cmd = bind.map_cmd

local plug_map = {
	-- Plugin markdown-preview
	["n|<F12>"] = map_cr("MarkdownPreviewToggle"):with_noremap():with_silent():with_desc("tool: Preview markdown"),
}

bind.nvim_load_mapping(plug_map)
