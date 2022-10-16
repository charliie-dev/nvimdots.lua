require("keymap.config")
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true, nowait = true }

-- Plugin keymaps

--- DAP keymaps
keymap("n", "<F5>", "<cmd>lua require('dap').continue()<cr>", opts) -- Launching debug sessions and resuming execution
keymap("n", "<F6>", "<cmd>lua require('dap').step_into()<cr>", opts)
keymap("n", "<F7>", "<cmd>lua require('dap').step_out()<cr>", opts)
keymap("n", "<F8>", "<cmd>lua require('dap').step_over()<<r>", opts)
keymap("n", "<F9>", "<cmd>lua require('dap').terminate()<cr>", opts)
keymap("n", "<leader>b", "<cmd>lua require('dap').toggle_breakpoint()<cr>", opts)
keymap("n", "<leader>B", "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", opts)
keymap(
	"n",
	"<leader>lp",
	"<cmd>lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>",
	opts
)
keymap("n", "<leader>dr", "<cmd>lua require('dap').repl.open()<cr>", opts)
keymap("n", "<leader>dl", "<cmd>lua require('dap').run_last()<cr>", opts)

--- Telescope keymap
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
keymap("n", "<leader>lg", "<cmd>Telescope live_grep<cr>", opts)
keymap("n", "<leader>\\", "<cmd>Telescope buffers<cr>", opts)
keymap("n", "<leader>;", "<cmd>Telescope help_tags<cr>", opts)
-- Telescope zoxide
keymap("n", "<leader>z", "<cmd>lua require('telescope').extensions.zoxide.list{}<cr>", opts)
-- Terminal project(git repo)
keymap("n", "<leader>rp", "<cmd>lua require('telescope').extensions.project.project{ display_type = 'full' }<cr>", opts)
-- Telescope harpoon
keymap("n", "<leader>hp", "<cmd>Telescope harpoon marks<cr>", opts)
---

--- NeoTree
keymap("n", "nt", "<cmd>NeoTreeFloatToggle<cr>", opts)

--- SymbolsOutline keymap
keymap("n", "<F3>", "<cmd>SymbolsOutline<cr>", opts)

--- fzf-lua
keymap("n", "fz", "<cmd>lua require('fzf-lua').files()<cr>", opts)

--- BufferLine keymap
-- Next BufferLine tab
keymap("n", "<tab>", "<cmd>BufferLineCycleNext<cr>", opts)
-- Previous BufferLine tab
keymap("n", "<S-tab>", "<cmd>BufferLineCyclePrev<cr>", opts)

--- bufdelete.nvim
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
-- keymap("n", "<leader>htm", '<cmd>lua require("harpoon.tmux").gotoTerminal(1)<cr>', opts)

--- Spectre keymap
-- Global find & replace
keymap("n", "<leader>Sr", '<cmd>lua require("spectre").open()<cr>', opts)
-- search in current file
keymap("n", "<leader>sr", '<cmd>lua require("spectre").open_file_search()<cr>', opts)

--- hlslens keymap
keymap("n", "n", [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]], opts)
keymap("n", "N", [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]], opts)
keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], opts)
keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], opts)
-- keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], opts)
-- keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], opts)
keymap("n", "nl", ":noh<CR>", opts)

--- Toggleterm keymap
keymap("n", "lg", "<cmd>lua _LAZYGIT_TOGGLE()<cr>", opts)

-- Packer keymap
keymap("n", "pc", "<cmd>PackerCompile<cr>", opts)
keymap("n", "ps", "<cmd>PackerSync<cr>", opts)
keymap("n", "pt", "<cmd>PackerStatus<cr>", opts)
