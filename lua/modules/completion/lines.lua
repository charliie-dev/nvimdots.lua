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
local c = require("kanagawa.colors").setup().diag
local bg = require("kanagawa.colors").setup().bg
local alpha = 0.1
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = c.error, bg = blend(c.error, bg, alpha) })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = c.warning, bg = blend(c.warning, bg, alpha) })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = c.info, bg = blend(c.info, bg, alpha) })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = c.hint, bg = blend(c.hint, bg, alpha) })

require("lsp_lines").setup()
-- Disable virtual_text since it's redundant due to lsp_lines.
vim.diagnostic.config({
	virtual_text = false,
})

vim.keymap.set("", "<Leader>ll", require("lsp_lines").toggle, { desc = "Toggle lsp_lines" })
