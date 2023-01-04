vim.api.nvim_command([[packadd nvim-treesitter]])

local normal_background = vim.api.nvim_get_hl_by_name("Normal", true).background
local blend_color = normal_background ~= nil and string.format("#%06x", normal_background) or "#000000"

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
