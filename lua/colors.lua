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

-- local colorscheme = "gruvbox-material"
--
-- local status, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
--
-- if not status then
--   vim.notify("Error: colorscheme " .. colorscheme .. " not found!")
--   vim.cmd("colorscheme desert")
-- end

vim.g.gruvbox_material_background = 'medium'
vim.g.gruvbox_material_better_performance = true
vim.g.gruvbox_material_diagnostic_line_highlight = true
vim.g.gruvbox_material_diagnostic_text_highlight = true
vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'
vim.g.gruvbox_material_disable_terminal_colors = true
vim.g.gruvbox_material_enable_bold = true
vim.g.gruvbox_material_foreground = 'mix'
vim.g.gruvbox_material_ui_contrast = 'high'
vim.cmd [[colorscheme gruvbox-material]]

-- Use everforest
-- vim.cmd [[colorscheme everforest]]
