local set = vim.keymap.set
local helpers = require("keymap.helpers")

-- Terminal escape
set("t", "<Esc><Esc>", [[<C-\><C-n>]], { silent = true })

-- Horizontal terminal
set("n", "<C-\\>", function()
	require("snacks").terminal.toggle(nil, { win = { position = "bottom", height = 0.3 } })
end, { silent = true, desc = "terminal: Toggle horizontal" })
set("i", "<C-\\>", function()
	vim.cmd("stopinsert")
	require("snacks").terminal.toggle(nil, { win = { position = "bottom", height = 0.3 } })
end, { silent = true, desc = "terminal: Toggle horizontal" })
set("t", "<C-\\>", function()
	require("snacks").terminal.toggle()
end, { silent = true, desc = "terminal: Toggle horizontal" })

-- Float terminal
set("n", "<A-d>", function()
	require("snacks").terminal.toggle(nil, { win = { style = "float" } })
end, { silent = true, desc = "terminal: Toggle float" })
set("i", "<A-d>", function()
	vim.cmd("stopinsert")
	require("snacks").terminal.toggle(nil, { win = { style = "float" } })
end, { silent = true, desc = "terminal: Toggle float" })
set("t", "<A-d>", function()
	require("snacks").terminal.toggle()
end, { silent = true, desc = "terminal: Toggle float" })

-- Lazygit
set("n", "lg", function()
	require("snacks").lazygit()
end, { silent = true, desc = "terminal: Toggle lazygit" })

-- TUI tools
set("n", "bt", function()
	helpers.toggle_float_term("btop", "btop")
end, { silent = true, desc = "terminal: Toggle btop" })
set("n", "lzd", function()
	helpers.toggle_float_term("lazydocker", "lazydocker")
end, { silent = true, desc = "terminal: Toggle lazydocker" })
set("n", "nvsmi", function()
	helpers.toggle_float_term("watch -n 1 nvidia-smi", "nvidia-smi")
end, { silent = true, desc = "terminal: Toggle nvidia-smi" })

-- Yazi
set("n", "yz", "<Cmd>Yazi<CR>", { silent = true, desc = "terminal: Toggle yazi" })
