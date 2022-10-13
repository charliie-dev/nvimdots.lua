-- Shorten function names
local keymap = vim.keymap.set

local opts = { noremap = true, silent = true, nowait = true }

-- Normal mode
-- Source current file
keymap("n", "<C-o>", ":so %<cr>", { noremap = true })
-- Save in normal mode
keymap("n", "<C-s>", ":w<cr>", { noremap = true })
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
keymap("x", "<leader>p", '"_dP', opts)

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
keymap("t", "jk", "<esc>:q<cr>", opts)
