local set = vim.keymap.set
local helpers = require("keymap.helpers")

-- Builtin: Terminal escape
set("t", "<Esc><Esc>", [[<C-\><C-n>]], { silent = true })

-- Plugin: snacks.nvim
local function toggle_horizontal_terminal()
	require("snacks").terminal.toggle(nil, { count = 1, win = { position = "bottom", height = 0.3 } })
end

local function toggle_floating_terminal()
	require("snacks").terminal.toggle(nil, { count = 2, win = { style = "float" } })
end

set({ "n", "t" }, "<C-\\>", toggle_horizontal_terminal, { silent = true, desc = "terminal: Toggle horizontal" })
set("i", "<C-\\>", function()
	vim.cmd("stopinsert")
	toggle_horizontal_terminal()
end, { silent = true, desc = "terminal: Toggle horizontal" })

set({ "n", "t" }, "<A-d>", toggle_floating_terminal, { silent = true, desc = "terminal: Toggle float" })
set("i", "<A-d>", function()
	vim.cmd("stopinsert")
	toggle_floating_terminal()
end, { silent = true, desc = "terminal: Toggle float" })

set("n", "lg", function()
	require("snacks").lazygit()
end, { silent = true, desc = "terminal: Toggle lazygit" })

set("n", "bt", function()
	helpers.toggle_float_term("btop", "btop")
end, { silent = true, desc = "terminal: Toggle btop" })
set("n", "lzd", function()
	helpers.toggle_float_term("lazydocker", "lazydocker")
end, { silent = true, desc = "terminal: Toggle lazydocker" })
set("n", "nvsmi", function()
	helpers.toggle_float_term("watch -n 1 nvidia-smi", "nvidia-smi")
end, { silent = true, desc = "terminal: Toggle nvidia-smi" })

-- Plugin: leaf.nvim
set("n", "lf", "<Cmd>Leaf<CR>", { silent = true, desc = "terminal: Toggle leaf markdown preview" })

-- Plugin: yazi.nvim
set("n", "yz", "<Cmd>Yazi<CR>", { silent = true, desc = "terminal: Toggle yazi" })
