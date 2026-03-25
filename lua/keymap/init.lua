local set = vim.keymap.set

-- Package manager: lazy.nvim
set("n", "<leader>ph", "<Cmd>Lazy<CR>", { silent = true, nowait = true, desc = "package: Show" })
set("n", "<leader>ps", "<Cmd>Lazy sync<CR>", { silent = true, nowait = true, desc = "package: Sync" })
set("n", "<leader>pu", "<Cmd>Lazy update<CR>", { silent = true, nowait = true, desc = "package: Update" })
set("n", "<leader>pi", "<Cmd>Lazy install<CR>", { silent = true, nowait = true, desc = "package: Install" })
set("n", "<leader>pl", "<Cmd>Lazy log<CR>", { silent = true, nowait = true, desc = "package: Log" })
set("n", "<leader>pc", "<Cmd>Lazy check<CR>", { silent = true, nowait = true, desc = "package: Check" })
set("n", "<leader>pd", "<Cmd>Lazy debug<CR>", { silent = true, nowait = true, desc = "package: Debug" })
set("n", "<leader>pp", "<Cmd>Lazy profile<CR>", { silent = true, nowait = true, desc = "package: Profile" })
set("n", "<leader>pr", "<Cmd>Lazy restore<CR>", { silent = true, nowait = true, desc = "package: Restore" })
set("n", "<leader>px", "<Cmd>Lazy clean<CR>", { silent = true, nowait = true, desc = "package: Clean" })

-- Category-based keymaps
require("keymap.viewport")
require("keymap.edit")
require("keymap.fuzzy")
require("keymap.terminal")
require("keymap.tool")
require("keymap.debug")

-- User keymaps
local ok, def = pcall(require, "user.keymap.init")
if ok then
	require("modules.utils.keymap").replace(def)
end
