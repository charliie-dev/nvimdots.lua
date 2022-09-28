local opts = { noremap = true, silent = true, nowait = true }

local term_opts = { silent = true }

-- Shorten function names
local keymap = vim.keymap.set

vim.g.mapleader = " "

-- Normal mode
-- Source current file
keymap("n", "<C-o>", ":so %<cr>", { noremap = true })
-- Save in normal mode
keymap("n", "<C-s>", ":w<cr>", {})
-- Insert newline in normal mode
keymap("n", "oo", "o", {})
-- Quick Exit from normal mode
keymap("n", "jk", "<esc>:q<cr>", { silent = true })
-- Format
keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", { noremap = true })
-- Increment/decrement
keymap("n", "+", "<C-a>", opts)
keymap("n", "-", "<C-x>", opts)
-- Select all
keymap("n", "<C-a>", "gg<S-v>G", opts)

--- Buffer keymap (A buffer is in-memory text of a file.)
-- Split buffer(window) vertically
keymap("n", "vs", ":vs<cr>", opts)
-- Split buffer(window) horizontally
keymap("n", "sp", ":sp<cr>", opts)
-- Move one buffer(window) right
keymap("n", "<C-L>", "<C-W><C-L>", opts)
-- Move one buffer(window) left
keymap("n", "<C-H>", "<C-W><C-H>", opts)
-- Move one buffer(window) up
keymap("n", "<C-K>", "<C-W><C-K>", opts)
-- Move one buffer(window) down
keymap("n", "<C-J>", "<C-W><C-J>", opts)

--- Window keymap (A windows is a viewport on a buffer.)
keymap("n", "<C-j>", "<C-w>j", opts) -- to bottom window
keymap("n", "<C-k>", "<C-w>k", opts) -- to top window
keymap("n", "<C-h>", "<C-w>h", opts) -- to left window
keymap("n", "<C-l>", "<C-w>l", opts) -- to right window

--- Tab keymap (A tab page is a collection of windows.)
-- Create a new tab
keymap("n", "tn", ":tabnew<cr>", opts)
-- Move to next tab
keymap("n", "tk", ":tabnext<cr>", opts)
-- Move to previous tab
keymap("n", "tj", ":tabprevious<cr>", opts)
-- Only keep current tab
keymap("n", "to", ":tabonly<cr>", opts)

-- NOTE: Keep things in paste register after paste it when visual selecting things to replace.
-- useful keymaps to replace text after copying thing
keymap("x", "<leader>p", "\"_dP", opts)

-- Insert mode
-- Save in insert mode
keymap("i", "<C-s>", "<esc>:w<cr>", {})
-- Jump to normal mode
keymap("i", "<leader>q", "<esc>", { silent = true })
-- Escape with jk
-- keymap("i", "jk", "<esc>`^", opts) -- replaced by better-escape.nvim

-- Visual mode
-- Stay in visual mode after indentation
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Command mode
-- Escape with jk
keymap("c", "jk", "<C-C><esc>", opts)

-- Terminal mode
-- Escape with jk
keymap("t", "jk", "<esc>:q<cr>", term_opts)

-- Plugin keymaps

--- Telescope keymap
keymap("n", "ff", "<cmd>Telescope find_files<cr>", opts)
keymap("n", "lg", "<cmd>Telescope live_grep<cr>", opts)
keymap("n", "<leader>\\", "<cmd>Telescope buffers<cr>", opts)
keymap("n", "<leader>;", "<cmd>Telescope help_tags<cr>", opts)
-- Telescope zoxide
keymap("n", "<leader>z", "<cmd>lua require('telescope').extensions.zoxide.list{}<cr>", opts)
-- Terminal project(git repo)
keymap("n", "<leader>rp", "<cmd>lua require('telescope').extensions.project.project{ display_type = 'full' }<cr>", opts)
-- Telescope harpoon
keymap("n", "<leader>hp", "<cmd>Telescope harpoon marks<cr>", opts)
-- Telescope command palette
keymap("n", "<leader>cp", "<cmd>Telescope command_palette<cr>", opts)
---

--- NvimTree
keymap("n", "<C-n>", ":NvimTreeToggle<cr>", opts)
keymap("n", "<F5>", ":NvimTreeRefresh<cr>", opts)
keymap("n", "<leader>n", ":NvimTreeFindFile<cr>", opts)

--- SymbolsOutline keymap
keymap("n", "<F8>", "<cmd>SymbolsOutline<cr>", opts)

--- fzf-lua
keymap("n", "fz", "<cmd>lua require('fzf-lua').files()<cr>", opts)

--- Hop keymap
-- Hopword
keymap("n", "<leader>h", ":HopWord<cr>", opts)
-- Hopline
keymap("n", "<leader>l", ":HopLine<cr>", opts)

--- BufferLine keymap
-- Next BufferLine tab
keymap("n", "<tab>", ":BufferLineCycleNext<cr>", opts)
-- Previous BufferLine tab
keymap("n", "<S-tab>", ":BufferLineCyclePrev<cr>", opts)
-- Choose BufferLine
keymap("n", "<leader><tab>", ":BufferLinePick<cr>", opts)

--- vim-bbye
keymap("n", "<F4>", "<cmd>Bdelete<cr>", opts)

--- Commnet keymap
---Line-comment toggle keymap, line = "gcc",
---Block-comment toggle keymap, block = "gbc",
---Add comment on the line above, above = "gcO",
---Add comment on the line below, below = "gco",
---Add comment at the end of line,	eol = "gcA",

--- Surround keymap
-- surr*ound_words             ysiw)           (surround_words)
-- *make strings               ys$"            "make strings"
-- [delete ar*ound me!]        ds]             delete around me!
-- remove <b>HTML t*ags</b>    dst             remove HTML tags
-- 'change quot*es'            cs'"            "change quotes"
-- <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
-- delete(functi*on calls)     dsf             function calls

--- Markdown keymap
-- `ge` open the md url link under the cursor in Vim for editing.
-- `gf` with force editing.
-- `]]` go to next header.
-- `[[` go to prev header.
-- `]h` go to current header.
-- `]u` go to parent header.
-- `:Toc` create a toc with headers.~~
-- `:InsertToc` insert toc table in current line.
-- `:InsertToc 3` specify how many levels of headers to display.
-- `:InsertNToc` add numbered list to `h2` headers.

--- Glow keymap
-- Usage:
-- :Glow [path-to-md-file] to view the md file.
-- `Ctrl-w + |` set window's width max.
-- `Ctrl-w + _` set window's height max

--- Tmux keymap
-- Move from Nvim windows to tmux panes
keymap("n", "<C-j>", '<cmd>lua require("tmux").move_bottom()<cr>', opts)
keymap("n", "<C-k>", '<cmd>lua require("tmux").move_top()<cr>', opts)
keymap("n", "<C-h>", '<cmd>lua require("tmux").move_left()<cr>', opts)
keymap("n", "<C-l>", '<cmd>lua require("tmux").move_right()<cr>', opts)
-- Neovim windos/Tmux panes resize
keymap("n", "<M-j>", '<cmd>lua require("tmux").resize_bottom()<cr>', opts)
keymap("n", "<M-k>", '<cmd>lua require("tmux").resize_top()<cr>', opts)
keymap("n", "<M-h>", '<cmd>lua require("tmux").resize_left()<cr>', opts)
keymap("n", "<M-l>", '<cmd>lua require("tmux").resize_right()<cr>', opts)

--- Harpoon keymap
-- Mark a file
keymap("n", "<leader>hm", '<cmd>lua require("harpoon.mark").add_file()<cr>', opts)
-- view all marked files
keymap("n", "<leader>ha", '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>', opts)
-- harpoon to the next file
keymap("n", "<leader>hj", '<cmd>lua require("harpoon.ui").nav_next()<>cr', opts)
-- harpoon to the previous file
keymap("n", "<leader>hk", '<cmd>lua require("harpoon.ui").nav_prev()<cr>', opts)
-- harpoon go to tmux windows, broken now. https://github.com/ThePrimeagen/harpoon/issues/180
keymap("n", "<leader>htm", '<cmd>lua require("harpoon.tmux").gotoTerminal(1)<cr>', opts)

--- Spectre keymap
-- Global find & replace
keymap("n", "<leader>S", '<cmd>lua require("spectre").open()<cr>', opts)
-- search in current file
keymap("n", "<leader>s", '<cmd>lua require("spectre").open_file_search()<cr>', opts)

--- Inc-rename keymap
keymap("n", "irn", function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })
-- keymap("n", "rn", ":IncRename ")

--- yanky keymap
keymap("n", "y", "<Plug>(YankyYank)", opts)
keymap("x", "y", "<Plug>(YankyYank)", opts)

--- nvim-osc52 keymap
-- In normal mode, <leader>c is an operator that will copy the given text to the clipboard.
keymap("n", "<leader>c", require('osc52').copy_operator, { expr = true })
-- In normal mode, <leader>cc will copy the current line.
keymap("n", "<leader>cc", "<leader>c_", { remap = true })
-- In visual mode, <leader>c will copy the current selection.
keymap("x", "<leader>c", require('osc52').copy_visual)

--- hlslens keymap
keymap('n', 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]], opts)
keymap('n', 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]], opts)
keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], opts)
keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], opts)
keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], opts)
keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], opts)
keymap('n', 'nl', ':noh<CR>', opts)

--- fm-nvim keymap
keymap("n", "lf", "<cmd>Lf<cr>", opts)
keymap("n", "lg", "<cmd>Lazygit<cr>", opts)
