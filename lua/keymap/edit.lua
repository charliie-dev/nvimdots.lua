local set = vim.keymap.set
local helpers = require("keymap.helpers")

-- Lazy-require treesitter-textobjects
local ts_to_select = function()
	return require("nvim-treesitter-textobjects.select")
end
local ts_to_swap = function()
	return require("nvim-treesitter-textobjects.swap")
end
local ts_to_repeat_move = function()
	return require("nvim-treesitter-textobjects.repeatable_move")
end

-- Builtin: Save & Quit
set("n", "<C-s>", "<Cmd>write<CR>", { silent = true, desc = "edit: Save file" })
set("n", "<C-q>", "<Cmd>wq<CR>", { desc = "edit: Save file and quit" })
set("n", "<A-S-q>", "<Cmd>q!<CR>", { desc = "edit: Force quit" })

-- Builtin: Insert mode
set("i", "<C-u>", "<C-G>u<C-U>", { desc = "edit: Delete previous block" })
set("i", "<C-b>", "<Left>", { desc = "edit: Move cursor to left" })
set("i", "<C-a>", "<ESC>^i", { desc = "edit: Move cursor to line start" })
set("i", "<C-s>", "<Esc>:w<CR>", { desc = "edit: Save file" })
set("i", "<C-q>", "<Esc>:wq<CR>", { desc = "edit: Save file and quit" })

-- Builtin: Command mode
set("c", "<C-b>", "<Left>", { desc = "edit: Left" })
set("c", "<C-f>", "<Right>", { desc = "edit: Right" })
set("c", "<C-a>", "<Home>", { desc = "edit: Home" })
set("c", "<C-e>", "<End>", { desc = "edit: End" })
set("c", "<C-d>", "<Del>", { desc = "edit: Delete" })
set("c", "<C-h>", "<BS>", { desc = "edit: Backspace" })
set("c", "<C-t>", [[<C-R>=expand("%:p:h") . "/" <CR>]], { desc = "edit: Complete path of current file" })

-- Builtin: Visual mode
set("v", "J", ":m '>+1<CR>gv=gv", { desc = "edit: Move this line down" })
set("v", "K", ":m '<-2<CR>gv=gv", { desc = "edit: Move this line up" })
set("v", "<", "<gv", { desc = "edit: Decrease indent" })
set("v", ">", ">gv", { desc = "edit: Increase indent" })

-- Builtin: Suckless
set("n", "Y", "y$", { desc = "edit: Yank text to EOL" })
set("n", "D", "d$", { desc = "edit: Delete text to EOL" })
set("n", "n", "nzzzv", { desc = "edit: Next search result" })
set("n", "N", "Nzzzv", { desc = "edit: Prev search result" })
set("n", "J", "mzJ`z", { desc = "edit: Join next line" })
set("n", "<S-Tab>", "<Cmd>normal za<CR>", { silent = true, desc = "edit: Toggle code fold" })
set("n", "<Esc>", function()
	helpers.flash_esc_or_noh()
end, { silent = true, desc = "edit: Clear search highlight" })
set("n", "+", "<C-a>", { silent = true, desc = "edit: Increment" })
set("n", "-", "<C-x>", { silent = true, desc = "edit: Decrement" })
set("n", "<C-a>", "gg0vG$", { silent = true, desc = "edit: Select all" })
set("x", "<C-a>", "<Esc>gg0vG$", { silent = true, desc = "edit: Select all" })
set("n", "<leader><leader>x", "<Cmd>!chmod +x %<CR>", { silent = true, desc = "edit: chmod +x current file" })

-- Plugin: dial
-- Call dial.map instead of dial's <Plug> mappings: requiring it loads dial on first use (the <Plug>
-- mappings only exist once CursorHold has loaded it), and Visual mode needs the "visual" augend
-- group, which the <Plug> mappings never pass. Reselect afterwards like the <Plug> mappings do.
local function dial(direction, visual)
	return function()
		if visual then
			require("dial.map").manipulate(direction, "visual", "visual")
			vim.cmd.normal({ "gv", bang = true })
		else
			require("dial.map").manipulate(direction, "normal")
		end
	end
end
set("n", "<leader>=", dial("increment"), { desc = "edit: Increment" })
set("n", "<leader>-", dial("decrement"), { desc = "edit: Decrement" })
set("v", "<leader>=", dial("increment", true), { desc = "edit: Increment" })
set("v", "<leader>-", dial("decrement", true), { desc = "edit: Decrement" })

-- Plugin: flash
set({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { silent = true, desc = "edit: Flash jump" })
set({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { silent = true, desc = "edit: Flash Treesitter" })
set("o", "r", function()
	require("flash").remote()
end, { silent = true, desc = "edit: Flash remote" })
set({ "o", "x" }, "R", function()
	require("flash").treesitter_search()
end, { silent = true, desc = "edit: Flash Treesitter search" })
set("c", "<C-s>", function()
	require("flash").toggle()
end, { silent = true, desc = "edit: Toggle Flash in search" })

-- Plugin: grug-far
set("n", "<leader>Ss", function()
	require("grug-far").open()
end, { silent = true, desc = "edit: Toggle search & replace panel" })
set("n", "<leader>Sp", function()
	require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { silent = true, desc = "edit: Search & replace current word (project)" })
set("v", "<leader>Sp", function()
	require("grug-far").with_visual_selection()
end, { silent = true, desc = "edit: Search & replace current word (project)" })
set("n", "<leader>Sf", function()
	require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
end, { silent = true, desc = "edit: Search & replace current word (file)" })

-- Plugin: suda.vim
set("n", "<A-s>", "<Cmd>SudaWrite<CR>", { silent = true, desc = "edit: Save file using sudo" })

-- Plugin: nvim-treesitter-textobjects (select)
set({ "x", "o" }, "af", function()
	ts_to_select().select_textobject("@function.outer", "textobjects")
end, { silent = true, desc = "edit: Select function.outer" })
set({ "x", "o" }, "if", function()
	ts_to_select().select_textobject("@function.inner", "textobjects")
end, { silent = true, desc = "edit: Select function.inner" })
set({ "x", "o" }, "ac", function()
	ts_to_select().select_textobject("@class.outer", "textobjects")
end, { silent = true, desc = "edit: Select class.outer" })
set({ "x", "o" }, "ic", function()
	ts_to_select().select_textobject("@class.inner", "textobjects")
end, { silent = true, desc = "edit: Select class.inner" })

-- Plugin: nvim-treesitter-textobjects (swap)
set("n", "<leader>a", function()
	ts_to_swap().swap_next("@parameter.inner")
end, { silent = true, desc = "edit: Swap parameter forward" })
set("n", "<leader>A", function()
	ts_to_swap().swap_previous("@parameter.outer")
end, { silent = true, desc = "edit: Swap parameter backward" })

-- Plugin: nvim-treesitter-textobjects (move)
-- Without a parser the move functions raise (their range lookup returns an empty table), so the
-- keys fall back to Vim's motion of the same name, keeping counts, Visual mode and operators.
local function ts_move(lhs, fn, query, desc)
	set({ "n", "x", "o" }, lhs, function()
		if not vim.treesitter.get_parser(0, nil, { error = false }) then
			return lhs
		end
		return ("<Cmd>lua require('nvim-treesitter-textobjects.move').%s(%q, 'textobjects')<CR>"):format(fn, query)
	end, { expr = true, silent = true, desc = desc })
end
ts_move("][", "goto_next_start", "@function.outer", "edit: Next function start")
ts_move("]m", "goto_next_start", "@class.outer", "edit: Next class start")
ts_move("]]", "goto_next_end", "@function.outer", "edit: Next function end")
ts_move("]M", "goto_next_end", "@class.outer", "edit: Next class end")
ts_move("[[", "goto_previous_start", "@function.outer", "edit: Prev function start")
ts_move("[m", "goto_previous_start", "@class.outer", "edit: Prev class start")
ts_move("[]", "goto_previous_end", "@function.outer", "edit: Prev function end")
ts_move("[M", "goto_previous_end", "@class.outer", "edit: Prev class end")

-- Plugin: nvim-treesitter-textobjects (repeat)
set({ "n", "x", "o" }, ";", function()
	ts_to_repeat_move().repeat_last_move_next()
end, { silent = true, desc = "edit: Repeat last move" })

-- Plugin: persisted.nvim
set("n", "<leader>ss", "<Cmd>Persisted save<CR>", { silent = true, desc = "session: Save" })
set("n", "<leader>sl", "<Cmd>Persisted load<CR>", { silent = true, desc = "session: Load current" })
set("n", "<leader>sd", "<Cmd>Persisted delete<CR>", { silent = true, desc = "session: Delete" })
