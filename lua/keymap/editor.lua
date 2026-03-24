local set = vim.keymap.set
local helpers = require("keymap.helpers")

local ts_to_select = require("nvim-treesitter-textobjects.select")
local ts_to_swap = require("nvim-treesitter-textobjects.swap")
local ts_to_move = require("nvim-treesitter-textobjects.move")
local ts_to_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

--
-- Builtins: Save & Quit
--
set("n", "<C-s>", "<Cmd>write<CR>", { silent = true, desc = "edit: Save file" })
set("n", "<C-q>", "<Cmd>wq<CR>", { desc = "edit: Save file and quit" })
set("n", "<A-S-q>", "<Cmd>q!<CR>", { desc = "edit: Force quit" })

--
-- Builtins: Insert mode
--
set("i", "<C-u>", "<C-G>u<C-U>", { desc = "edit: Delete previous block" })
set("i", "<C-b>", "<Left>", { desc = "edit: Move cursor to left" })
set("i", "<C-a>", "<ESC>^i", { desc = "edit: Move cursor to line start" })
set("i", "<C-s>", "<Esc>:w<CR>", { desc = "edit: Save file" })
set("i", "<C-q>", "<Esc>:wq<CR>", { desc = "edit: Save file and quit" })

--
-- Builtins: Command mode
--
set("c", "<C-b>", "<Left>", { desc = "edit: Left" })
set("c", "<C-f>", "<Right>", { desc = "edit: Right" })
set("c", "<C-a>", "<Home>", { desc = "edit: Home" })
set("c", "<C-e>", "<End>", { desc = "edit: End" })
set("c", "<C-d>", "<Del>", { desc = "edit: Delete" })
set("c", "<C-h>", "<BS>", { desc = "edit: Backspace" })
set("c", "<C-t>", [[<C-R>=expand("%:p:h") . "/" <CR>]], { desc = "edit: Complete path of current file" })

--
-- Builtins: Visual mode
-- Move selected lines Up/Down with auto-indent, @ThePrimeagen
--
set("v", "J", ":m '>+1<CR>gv=gv", { desc = "edit: Move this line down" })
set("v", "K", ":m '<-2<CR>gv=gv", { desc = "edit: Move this line up" })
set("v", "<", "<gv", { desc = "edit: Decrease indent" })
set("v", ">", ">gv", { desc = "edit: Increase indent" })

--
-- Builtin: suckless
--
set("n", "Y", "y$", { desc = "edit: Yank text to EOL" })
set("n", "D", "d$", { desc = "edit: Delete text to EOL" })
set("n", "n", "nzzzv", { desc = "edit: Next search result" })
set("n", "N", "Nzzzv", { desc = "edit: Prev search result" })
-- Keep cursor inplace if below line being append to current line when moving, @ThePrimeagen
set("n", "J", "mzJ`z", { desc = "edit: Join next line" })
set("n", "<S-Tab>", "<Cmd>normal za<CR>", { silent = true, desc = "edit: Toggle code fold" })
set("n", "<Esc>", function()
	helpers.flash_esc_or_noh()
end, { silent = true, desc = "edit: Clear search highlight" })
set("n", "<leader>o", "<Cmd>setlocal spell! spelllang=en_us<CR>", { desc = "edit: Toggle spell check" })
set("n", "+", "<C-a>", { silent = true, desc = "edit: Increment" })
set("n", "-", "<C-x>", { silent = true, desc = "edit: Decrement" })
set("n", "<C-a>", "gg0vG$", { silent = true, desc = "edit: Select all" })
set("x", "<C-a>", "<Esc>gg0vG$", { silent = true, desc = "edit: Select all" })
-- -- chmod +x current file, @ThePrimeagen
set("n", "<leader><leader>x", "<Cmd>!chmod +x %<CR>", { silent = true, desc = "file: chmod +x current file" })
set("n", "<C-p>", "<Nop>", { silent = true, desc = "Disable native cmp" })
set("n", "<C-n>", "<Nop>", { silent = true, desc = "Disable native cmp" })

--
-- Plugin: persisted.nvim
--
set("n", "<leader>ss", "<Cmd>SessionSave<CR>", { silent = true, desc = "session: Save" })
set("n", "<leader>sl", "<Cmd>SessionLoad<CR>", { silent = true, desc = "session: Load current" })
set("n", "<leader>sd", "<Cmd>SessionDelete<CR>", { silent = true, desc = "session: Delete" })

--
-- Plugin: comment-frame
--
set("n", "<leader>cf", function()
	require("nvim-comment-frame").add_comment()
end, { desc = "edit: Add comment box around the texts" })
set("n", "<leader>cF", function()
	require("nvim-comment-frame").add_multiline_comment()
end, { desc = "edit: Add comment box around multi lines of texts" })

--
-- Plugin: diffview.nvim
--
set("n", "<leader>gd", "<Cmd>DiffviewOpen<CR>", { silent = true, desc = "git: Show diff" })
set("n", "<leader>gD", "<Cmd>DiffviewClose<CR>", { silent = true, desc = "git: Close diff" })

--
-- Plugin: flash
--
-- set({"n","x","o"}, "s", function()
-- 	require("flash").jump()
-- end, { silent = true, desc = "edit: Flash search" })
-- set({"n","x","o"}, "S", function()
-- 	require("flash").treesitter()
-- end, { silent = true, desc = "edit: Flash Treesitter" })
-- set("c", "<C-s>", function()
-- 	require("flash").toggle()
-- end, { silent = true, desc = "editi: Flash Telescope" })

--- Plugin: mini.surround
-- see `:help MiniSurround`

--- Plugin: mini.ai
-- see `:help MiniAI`
-- see: https://youtu.be/6V8jdqdygB4

--
-- Plugin: grug-far
--
set("n", "<leader>Ss", function()
	require("grug-far").open()
end, { silent = true, desc = "editn: Toggle search & replace panel" })
set("n", "<leader>Sp", function()
	require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { silent = true, desc = "editn: search&replace current word (project)" })
set("v", "<leader>Sp", function()
	require("grug-far").with_visual_selection()
end, { silent = true, desc = "edit: search & replace current word (project)" })
set("n", "<leader>Sf", function()
	require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
end, { silent = true, desc = "editn: search & replace current word (file)" })

--
-- Plugin: suda.vim
--
set("n", "<A-s>", "<Cmd>SudaWrite<CR>", { silent = true, desc = "editn: Save file using sudo" })

--
-- Plugin: nvim-treesitter-textobjects
--

-- Text objects: select
set({ "x", "o" }, "af", function()
	ts_to_select.select_textobject("@function.outer", "textobjects")
end, { silent = true, desc = "editxo: Select function.outer" })
set({ "x", "o" }, "if", function()
	ts_to_select.select_textobject("@function.inner", "textobjects")
end, { silent = true, desc = "editxo: Select function.inner" })
set({ "x", "o" }, "ac", function()
	ts_to_select.select_textobject("@class.outer", "textobjects")
end, { silent = true, desc = "editxo: Select class.outer" })
set({ "x", "o" }, "ic", function()
	ts_to_select.select_textobject("@class.inner", "textobjects")
end, { silent = true, desc = "editoxo: Select class.inner" })

-- Text objects: swap
set("n", "<leader>a", function()
	ts_to_swap.swap_next("@parameter.inner")
end, { silent = true, desc = "editn: Swap parameter.inner" })
set("n", "<leader>A", function()
	ts_to_swap.swap_next("@parameter.outer")
end, { silent = true, desc = "editn: Swap parameter.outer" })

-- Text objects: move
set({ "n", "x", "o" }, "][", function()
	ts_to_move.goto_next_start("@function.outer", "textobjects")
end, { silent = true, desc = "editnxo: Move to next function.outer start" })
set({ "n", "x", "o" }, "]m", function()
	ts_to_move.goto_next_start("@class.outer", "textobjects")
end, { silent = true, desc = "editnxo: Move to next class.outer start" })
set({ "n", "x", "o" }, "]]", function()
	ts_to_move.goto_next_end("@function.outer", "textobjects")
end, { silent = true, desc = "editnxo: Move to next function.outer end" })
set({ "n", "x", "o" }, "]M", function()
	ts_to_move.goto_next_end("@class.outer", "textobjects")
end, { silent = true, desc = "editnxo: Move to next class.outer end" })
set({ "n", "x", "o" }, "[[", function()
	ts_to_move.goto_previous_start("@function.outer", "textobjects")
end, { silent = true, desc = "editnxo: Move to previous function.outer start" })
set({ "n", "x", "o" }, "[m", function()
	ts_to_move.goto_previous_start("@class.outer", "textobjects")
end, { silent = true, desc = "editnxo: Move to previous class.outer start" })
set({ "n", "x", "o" }, "[]", function()
	ts_to_move.goto_previous_end("@function.outer", "textobjects")
end, { silent = true, desc = "editnxo: Move to previous function.outer end" })
set({ "n", "x", "o" }, "[M", function()
	ts_to_move.goto_previous_end("@class.outer", "textobjects")
end, { silent = true, desc = "editnxo: Move to previous class.outer end" })

-- movements repeat
set({ "n", "x", "o" }, ";", function()
	ts_to_repeat_move.repeat_last_move_next()
end, { silent = true, desc = "editnxo: Repeat last move" })
