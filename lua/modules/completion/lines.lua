local util = require("utils")

-- Custom vertual text highlight groups for lsp_lines
local c = require("kanagawa.colors").setup().diag
local bg = require("kanagawa.colors").setup().bg
local alpha = 0.1
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = c.error, bg = util.blend(c.error, bg, alpha) })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = c.warning, bg = util.blend(c.warning, bg, alpha) })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = c.info, bg = util.blend(c.info, bg, alpha) })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = c.hint, bg = util.blend(c.hint, bg, alpha) })

require("lsp_lines").setup()
-- Disable virtual_text since it's redundant due to lsp_lines.
vim.diagnostic.config({
	virtual_text = false,
})

vim.keymap.set("", "<Leader>ll", require("lsp_lines").toggle, { desc = "Toggle lsp_lines" })
