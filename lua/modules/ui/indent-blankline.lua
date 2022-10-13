require("indent_blankline").setup({
	char = "│",
	show_first_indent_level = true,
	filetype_exclude = {
		"", -- for all buffers without a file type
		"NvimTree",
		"TelescopePrompt",
		"dashboard",
		"dotooagenda",
		"flutterToolsOutline",
		"fugitive",
		"git",
		"gitcommit",
		"help",
		"json",
		"log",
		"markdown",
		"packer",
		"peekaboo",
		"startify",
		"todoist",
		"txt",
		"text",
		"undotree",
		"vimwiki",
		"vista",
	},
	buftype_exclude = { "terminal", "nofile" },
	show_trailing_blankline_indent = false,
	show_current_context = true,
	context_patterns = {
		"class",
		"function",
		"method",
		"block",
		"list_literal",
		"selector",
		"^if",
		"^table",
		"if_statement",
		"while",
		"for",
		"type",
		"var",
		"import",
	},
	space_char_blankline = " ",
})

-- change indentline color for current scoop.
-- Below functions are from "folke/tokyonight.nvim/lua/tokyonight/util.lua" to creat the glowy feeling.
---@param c  string
local function hexToRgb(c)
	c = string.lower(c)
	return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

---@param foreground string foreground color
---@param background string background color
---@param alpha number|string number between 0 and 1. 0 results in bg, 1 results in fg
local function blend(foreground, background, alpha)
	alpha = type(alpha) == "string" and (tonumber(alpha, 16) / 0xff) or alpha
	local bg = hexToRgb(background)
	local fg = hexToRgb(foreground)

	local blendChannel = function(i)
		local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
		return math.floor(math.min(math.max(0, ret), 255) + 0.5)
	end

	return string.format("#%02x%02x%02x", blendChannel(1), blendChannel(2), blendChannel(3))
end

-- Custom vertual text highlight groups for lsp_lines
local c = require("kanagawa.colors").setup()
local bg = require("kanagawa.colors").setup().bg
local alpha = 0.3
vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = c.pp, bg = blend(c.pp, bg, alpha) })
-- vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = "#ec5241" })
