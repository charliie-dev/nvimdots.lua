-- Remove ALL autocommands for the current group to prevent autocmds loading twice.
vim.cmd([[autocmd!]])

-- Basic

-- Fast startup
--- vim.cmd([[source $HOME/.config/nvim/lua/autocommands.vim]])
vim.cmd([[source $HOME/.config/nvim/plugin/packer_compiled.lua]])
--- impatient needs to be setup before any other lua plugin is loaded
require("config.impatient")


require("colors")
require("events")
require("icons")
require("keymaps")
require("options")
require("plugins")

-- Plugin Configa
-- require("config.navic")
-- require("config.surround")
-- require("config.renamer")
require("config.alpha")
require("config.autopairs")
require("config.autosave")
require("config.bufferline")
require("config.cmp")
require("config.colorizer")
require("config.comment")
require("config.conflict-marker")
require("config.copilot")
require("config.dap")  -- TODO:
require("config.gitblame")
require("config.gitsigns")
require("config.glow-hover")
require("config.gps")
require("config.harpoon")
require("config.hop")
require("config.illuminate")
require("config.indentline")
require("config.lsp")
require("config.lualine")
require("config.mustache-handlebars")
require("config.neoscroll")
require("config.notify")
require("config.numb")
require("config.nvim-tree")
require("config.nvim-web-devicons")
require("config.sniprun")
require("config.spectre")
require("config.symbols-outline")
require("config.telescope")
require("config.tmux")
require("config.todo-comments")
require("config.toggleterm")
require("config.treesitter")
require("config.wilder")
require("config.winbar")
require("config.yanky")

vim.cmd [[source $HOME/.config/nvim/lua/config/mkdp.vim]]
vim.cmd [[source $HOME/.config/nvim/lua/config/vimtex.vim]]
vim.cmd [[source $HOME/.config/nvim/lua/config/markdown.vim]]
vim.cmd [[source $HOME/.config/nvim/lua/config/sandwich.vim]]
vim.cmd [[source $HOME/.config/nvim/lua/config/lastplace.vim]]
vim.cmd [[source $HOME/.config/nvim/lua/config/better-escape.vim]]
