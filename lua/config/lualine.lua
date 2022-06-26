local status, lualine = pcall(require, "lualine")
if not status then
  return
end

local gb_status, git_blame = pcall(require, "gitblame")
if not gb_status then
	return
end

local hide_in_width = function()
  return vim.fn.winwidth(0) > 80
end

local gitblame_cond = function()
  return ( git_blame.is_blame_text_available() and hide_in_width() )
end

--- everforest theme {{{
local everforest_palette = {
  bg0 = { "#2f383e", "235" },
  bg1 = { "#374247", "236" },
  bg2 = { "#404c51", "237" },
  bg3 = { "#4a555b", "238" },
  bg4 = { "#525c62", "239" },
  bg5 = { "#596763", "240" },
  bg_visual = { "#573e4c", "52" },
  bg_red = { "#544247", "52" },
  bg_green = { "#445349", "22" },
  bg_blue = { "#3b5360", "17" },
  bg_yellow = { "#504f45", "136" },

  fg = { "#d3c6aa", "223" },
  red = { "#e67e80", "167" },
  orange = { "#e69875", "208" },
  yellow = { "#dbbc7f", "214" },
  green = { "#a7c080", "142" },
  aqua = { "#83c092", "108" },
  blue = { "#7fbbb3", "109" },
  purple = { "#d699b6", "175" },
  grey0 = { "#7a8478", "243" },
  grey1 = { "#859289", "245" },
  grey2 = { "#9da9a0", "247" },
  statusline1 = { "#a7c080", "142" },
  statusline2 = { "#d3c6aa", "223" },
  statusline3 = { "#e67e80", "167" },
  none = { "NONE", "NONE" },
}

local everforest_theme = {
  normal = {
    a = { bg = everforest_palette.statusline1[1], fg = everforest_palette.bg0[1], gui = "bold" },
    b = { bg = everforest_palette.bg3[1], fg = everforest_palette.grey2[1] },
    c = { bg = everforest_palette.bg1[1], fg = everforest_palette.grey1[1] },
  },
  insert = {
    a = { bg = everforest_palette.statusline2[1], fg = everforest_palette.bg0[1], gui = "bold" },
    b = { bg = everforest_palette.bg3[1], fg = everforest_palette.fg[1] },
    c = { bg = everforest_palette.bg1[1], fg = everforest_palette.fg[1] },
  },
  visual = {
    a = { bg = everforest_palette.statusline3[1], fg = everforest_palette.bg0[1], gui = "bold" },
    b = { bg = everforest_palette.bg3[1], fg = everforest_palette.fg[1] },
    c = { bg = everforest_palette.bg1[1], fg = everforest_palette.fg[1] },
  },
  replace = {
    a = { bg = everforest_palette.orange[1], fg = everforest_palette.bg0[1], gui = "bold" },
    b = { bg = everforest_palette.bg3[1], fg = everforest_palette.fg[1] },
    c = { bg = everforest_palette.bg1[1], fg = everforest_palette.fg[1] },
  },
  command = {
    a = { bg = everforest_palette.aqua[1], fg = everforest_palette.bg0[1], gui = "bold" },
    b = { bg = everforest_palette.bg3[1], fg = everforest_palette.fg[1] },
    c = { bg = everforest_palette.bg1[1], fg = everforest_palette.fg[1] },
  },
  terminal = {
    a = { bg = everforest_palette.purple[1], fg = everforest_palette.bg0[1], gui = "bold" },
    b = { bg = everforest_palette.bg3[1], fg = everforest_palette.fg[1] },
    c = { bg = everforest_palette.bg1[1], fg = everforest_palette.fg[1] },
  },
  inactive = {
    a = { bg = everforest_palette.bg1[1], fg = everforest_palette.grey1[1] },
    b = { bg = everforest_palette.bg1[1], fg = everforest_palette.grey1[1] },
    c = { bg = everforest_palette.bg1[1], fg = everforest_palette.grey1[1] },
  },
}

vim.api.nvim_set_hl(0, "SLGitIcon", { fg = "#E8AB53", bg = everforest_palette.bg2[1] })
vim.api.nvim_set_hl(0, "SLBranchName", { fg = "#D4D4D4", bg = everforest_palette.bg2[1], bold = false })
vim.api.nvim_set_hl(0, "SLbg2", { fg = "#D4D4D4", bg = everforest_palette.bg2[1] })
--- }}}

local diagnostics = {
  "diagnostics",
  sources = { "nvim_diagnostic" },
  sections = { "error", "warn", "hint", "info" },
  diagnostics_color = {
    error = { fg = "#ec5241", bg = everforest_palette.bg2[1] },
    warn = { fg = "#efb839", bg = everforest_palette.bg2[1] },
    hint = { fg = "#dbbc7f", bg = everforest_palette.bg2[1] },
    info = { fg = "#7ea9a7", bg = everforest_palette.bg2[1] },
  },
  update_in_insert = false,
  always_visible = false,
}

local branch = {
  "branch",
  icons_enabled = true,
  icon = "%#SLGitIcon#" .. "" .. "%*" .. "%#SLBranchName#",
  -- colored = true,
}

local diff = {
  "diff",
  colored = true,
  diff_color = {
    -- Same color values as the general color option can be used here.
    added = { fg = "#35a77c", bg = everforest_palette.bg2[1] },
    modified = { fg = "#3a94c5", bg = everforest_palette.bg2[1] },
    removed = { fg = "#f85552", bg = everforest_palette.bg2[1] },
  },
  symbols = { added = "+", modified = "~", removed = "-" },
  -- symbols = { added = icons.git.Add .. " ", modified = icons.git.Mod .. " ", removed = icons.git.Remove .. " " }, -- changes diff symbols
  cond = hide_in_width,
  separator = "│ ",
}

local filename = {
  "filename",
  file_status = true,
  path = 1,
  shorting_target = 40,
  symbols = {
    modified = "[+]", -- Text to show when the file is modified.
    readonly = "[-]", -- Text to show when the file is non-modifiable or readonly.
    unnamed = "[No Name]", -- Text to show for unnamed buffers.
  },
}

-- local current_signature = function()
--   if not pcall(require, "lsp_signature") then
--     return
--   end
--   local sig = require("lsp_signature").status_line(30)
--   -- return "%#SLbg2#" .. sig.hint
--   -- print(sig)
--   return sig.label .. sig.hint
-- end

local spaces = {
  function()
    return "spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
  end,
  padding = { left = 2, right = 0 },
  color = "SLbg2",
}

local filetype = {
  "filetype",
  color = "SLbg2",
  padding = { left = 2, right = 1 },
}

local fileformat = {
  "fileformat",
  color = "SLbg2",
}

local progress = {
  "progress",
  color = "SLbg2",
  padding = { left = 0, right = 2 },
}

lualine.setup({
  options = {
    globalstatus = true,
    icons_enabled = true,
    theme = everforest_theme,
    component_separators = "|",
    section_separators = { left = "", right = "" },
    disabled_filetypes = { "alpha", "dashboard", "NvimTree" },
    always_divide_middle = false,
  },
  sections = {
    lualine_a = {
      { "mode", separator = { left = "" }, right_padding = 2 },
    },
    lualine_b = { diagnostics, branch, diff },
    lualine_c = {
      -- { filename, cond = hide_in_width },
      -- { current_signature, cond = hide_in_width },
      { git_blame.get_current_blame_text, cond = gitblame_cond },
    },
    lualine_x = {},
    lualine_y = { spaces, filetype, fileformat, progress },
    lualine_z = {
      { "location", separator = { right = "" }, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = { filename },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "location" },
  },
  tabline = {},
  extensions = {},
})
