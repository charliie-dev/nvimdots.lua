local status, navic = pcall(require, "nvim-navic")
if not status then
  return
end

local icons = require "icons"

navic.setup({
  icons = {
    File          = " ",
    Module        = " ",
    Namespace     = " ",
    Package       = " ",
    Class         = " ",
    Method        = " ",
    Property      = " ",
    Field         = " ",
    Constructor   = " ",
    Enum          = "練",
    Interface     = "練",
    Function      = " ",
    Variable      = " ",
    Constant      = " ",
    String        = " ",
    Number        = " ",
    Boolean       = "◩ ",
    Array         = " ",
    Object        = " ",
    Key           = " ",
    Null          = "ﳠ ",
    EnumMember    = " ",
    Struct        = " ",
    Event         = " ",
    Operator      = " ",
    TypeParameter = " ",
  },
  highlight = true,
  separator = " " .. icons.ui.ChevronRight,
  depth_limit = 0,
  depth_limit_indicator = "..",
})

vim.api.nvim_set_hl(0, "NavicIconsFile",          {default = true, fg = "#D4D4D4", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsModule",        {default = true, fg = "#4EC9B0", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsNamespace",     {default = true, fg = "#4EC9B0", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsPackage",       {default = true, fg = "#4EC9B0", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsClass",         {default = true, fg = "#E8AB53", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsMethod",        {default = true, fg = "#B180D7", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsProperty",      {default = true, fg = "#9CDCFE", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsField",         {default = true, fg = "#9CDCFE", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsConstructor",   {default = true, fg = "#E8AB53", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsEnum",          {default = true, fg = "#E8AB53", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsInterface",     {default = true, fg = "#E8AB53", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsFunction",      {default = true, fg = "#B180D7", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsVariable",      {default = true, fg = "#9CDCFE", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsConstant",      {default = true, fg = "#4FC1FF", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsString",        {default = true, fg = "#CE9178", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsNumber",        {default = true, fg = "#B5CEA8", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsBoolean",       {default = true, fg = "#569CD6", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsArray",         {default = true, fg = "#E8AB53", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsObject",        {default = true, fg = "#E8AB53", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsKey",           {default = true, fg = "#D4D4D4", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsNull",          {default = true, fg = "#569CD6", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsEnumMember",    {default = true, fg = "#4FC1FF", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsStruct",        {default = true, fg = "#E8AB53", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsEvent",         {default = true, fg = "#FFCC66", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsOperator",      {default = true, fg = "#D4D4D4", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicIconsTypeParameter", {default = true, fg = "#9CDCFE", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicText",               {default = true, fg = "#ffffff", bg = 'NONE'})
vim.api.nvim_set_hl(0, "NavicSeparator",          {default = true, fg = "#606060", bg = 'NONE'})

-- codicon icons
-- icons = {
--   File =          ' ',
--   Module =        ' ',
--   Namespace =     ' ',
--   Package =       ' ',
--   Class =         ' ',
--   Method =        ' ',
--   Property =      ' ',
--   Field =         ' ',
--   Constructor =   ' ',
--   Enum =          ' ',
--   Interface =     ' ',
--   Function =      ' ',
--   Variable =      ' ',
--   Constant =      ' ',
--   String =        ' ',
--   Number =        ' ',
--   Boolean =       ' ',
--   Array =         ' ',
--   Object =        ' ',
--   Key =           ' ',
--   Null =          ' ',
--   EnumMember =    ' ',
--   Struct =        ' ',
--   Event =         ' ',
--   Operator =      ' ',
--   TypeParameter = ' '
-- },
