-- Highlight groups
-- local util = require("utils")
-- local c = require("kanagawa.colors").setup()

-- vim.api.nvim_set_hl(0, "TreeClimberHighlight", { background = util.blend(c.pp, c.bg, 0.3) })
-- vim.api.nvim_set_hl(0, "TreeClimberSiblingBoundary", { background = c.bg_light3 })
-- vim.api.nvim_set_hl(0, "TreeClimberSibling", { background = util.blend(c.bg_light3, c.bg, 0.6), bold = true })
-- vim.api.nvim_set_hl(0, "TreeClimberParent", { background = util.blend(c.fg, c.bg, 0.2) })
-- vim.api.nvim_set_hl(0, "TreeClimberParentStart", { background = util.blend(c.fg, c.bg, 0.1), bold = true })

vim.api.nvim_command([[packadd lush.nvim]])
local color = require("nvim-treeclimber.hi")
local bg = color.bg_hsluv("Normal")
local fg = color.fg_hsluv("Normal")
local dim = bg.mix(fg, 20)

vim.api.nvim_set_hl(0, "TreeClimberHighlight", { background = dim.hex })
vim.api.nvim_set_hl(0, "TreeClimberSiblingBoundary", { background = color.terminal_color_5.hex })
vim.api.nvim_set_hl(0, "TreeClimberSibling", { background = color.terminal_color_5.mix(bg, 40).hex, bold = true })
vim.api.nvim_set_hl(0, "TreeClimberParent", { background = bg.mix(fg, 2).hex })
vim.api.nvim_set_hl(0, "TreeClimberParentStart", { background = color.terminal_color_4.mix(bg, 10).hex, bold = true })
