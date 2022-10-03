-- Remove ALL autocommands for the current group to prevent autocmds loading twice.
vim.cmd([[autocmd!]])

-- Fast startup
--- impatient needs to be setup before any other lua plugin is loaded
_G.__luacache_config = {
  chunks = {
    enable = true,
    path = vim.fn.stdpath('cache')..'/luacache_chunks',
  },
  modpaths = {
    enable = true,
    path = vim.fn.stdpath('cache')..'/luacache_modpaths',
  }
}
require('impatient')

require("colors")
require("events")
require("icons")
require("keymaps")
require("options")
require("plugins")

-- Plugin Config
require("config.alpha")
require("config.autopairs")
require("config.autosave")
require("config.autotag")
require("config.better-escape")
require("config.bufferline")
require("config.cinnamon")
require("config.cmp")
require("config.colorizer")
require("config.colortils")
require("config.comment")
require("config.copilot")
require("config.dap")
require("config.git-nvim")
require("config.gitblame")
require("config.gitconflict")
require("config.gitsigns")
require("config.glow-hover")
require("config.harpoon")
require("config.hlslens")
require("config.hop")
require("config.illuminate")
require("config.inc-rename")
require("config.indentline")
require("config.lastplace")
require("config.lsp")
require("config.lualine")
require("config.notify")
require("config.numb")
require("config.nvim-tree")
require("config.nvim-web-devicons")
require("config.osc52")
require("config.pretty-fold")
require("config.scrollbar")
require("config.sniprun")
require("config.spectre")
require("config.surround")
require("config.symbols-outline")
require("config.telescope")
require("config.tmux")
require("config.todo-comments")
require("config.toggleterm")
require("config.treesitter")
require("config.wilder")
require("config.yanky")

vim.cmd [[source $HOME/.config/nvim/lua/config/mkdp.vim]]
vim.cmd [[source $HOME/.config/nvim/lua/config/vimtex.vim]]
vim.cmd [[source $HOME/.config/nvim/lua/config/markdown.vim]]
