local color_config = {
	background = "dark",
	pumblend = 10,
	termguicolors = true,
	wildoptions = "pum",
	winblend = 0,
}

for k, v in pairs(color_config) do
	vim.opt[k] = v
end

--
--local status, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
--
--if not status then
--  vim.notify("Error: colorscheme " .. colorscheme .. " not found!")
--  vim.cmd("colorscheme desert")
--end

vim.g.gruvbox_material_background = "medium"
vim.g.gruvbox_material_better_performance = true
vim.g.gruvbox_material_diagnostic_line_highlight = true
vim.g.gruvbox_material_diagnostic_text_highlight = true
vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
vim.g.gruvbox_material_disable_terminal_colors = true
vim.g.gruvbox_material_enable_bold = true
vim.g.gruvbox_material_foreground = "mix"
vim.g.gruvbox_material_ui_contrast = "high"
vim.cmd([[colorscheme gruvbox-material]])

-- Use everforest
-- vim.cmd [[colorscheme everforest]]

-- Use decay
-- local decay_status, decay = pcall(require, "decay")
--
-- if not decay_status then
--   return
-- end
--
-- decay.setup {
--   dark = false,
--   nvim_tree = {
--     contrast = true,
--   },
-- }

-- Use Kanagawa
-- local kana_status, kanagawa = pcall(require, "kanagawa")
--
-- if not kana_status then
-- 	return
-- end
--
-- kanagawa.setup({
-- 	undercurl = true, -- enable undercurls
-- 	commentStyle = { italic = false },
-- 	functionStyle = {},
-- 	keywordStyle = { italic = false },
-- 	statementStyle = { bold = true },
-- 	typeStyle = {},
-- 	variablebuiltinStyle = { italic = true },
-- 	specialReturn = true, -- special highlight for the return keyword
-- 	specialException = true, -- special highlight for exception handling keywords
-- 	transparent = false, -- do not set background color
-- 	dimInactive = false, -- dim inactive window `:h hl-NormalNC`
-- 	globalStatus = false, -- adjust window separators highlight for laststatus=3
-- 	terminalColors = true, -- define vim.g.terminal_color_{0,17}
-- 	colors = {},
-- 	overrides = {},
-- })
--
-- -- setup must be called before loading
-- vim.cmd("colorscheme kanagawa")
