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

local util = require("utils")

-- Custom vertual text highlight groups for lsp_lines
local c = require("kanagawa.colors").setup()
local bg = require("kanagawa.colors").setup().bg
local alpha = 0.3
vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = c.pp, bg = util.blend(c.pp, bg, alpha) })
-- vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = "#ec5241" })
