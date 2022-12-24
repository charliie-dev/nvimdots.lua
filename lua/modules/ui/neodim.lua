local util = require("utils")
local blend_color = util.hlToRgb("Normal", true)

require("neodim").setup({
	alpha = 0.45,
	blend_color = blend_color,
	update_in_insert = {
		enable = true,
		delay = 100,
	},
	hide = {
		virtual_text = false,
		signs = false,
		underline = false,
	},
})
