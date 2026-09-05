local helpers = require("keymap.helpers")
local set = vim.keymap.set

-- Plugin: snacks.nvim
set("n", "<C-p>", function()
	helpers.command_panel()
end, { silent = true, desc = "tool: Command panel" })

-- Plugin: edgy.nvim
set("n", "<C-n>", function()
	require("edgy").toggle("left")
end, { silent = true, desc = "tool: Toggle sidebar" })

-- Plugin: sniprun
set("v", "<leader>r", ":SnipRun<CR>", { silent = true, desc = "tool: Run code by range" })
set("n", "<leader>r", "<Cmd>%SnipRun<CR>", { silent = true, desc = "tool: Run code by file" })

-- Plugin: overseer.nvim
set("n", "<leader>or", "<Cmd>OverseerRun<CR>", { silent = true, desc = "tool: Overseer run" })
set("n", "<leader>ot", "<Cmd>OverseerToggle<CR>", { silent = true, desc = "tool: Overseer toggle" })
set("n", "<leader>oa", "<Cmd>OverseerTaskAction<CR>", { silent = true, desc = "tool: Overseer task action" })

-- Plugin: quicker.nvim
set("n", "<leader>q", function()
	require("quicker").toggle()
end, { silent = true, desc = "tool: Toggle quickfix" })
set("n", "<leader>Q", function()
	require("quicker").toggle({ loclist = true })
end, { silent = true, desc = "tool: Toggle loclist" })
set("n", "<leader>qe", function()
	require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
end, { silent = true, desc = "tool: Expand quickfix context" })
set("n", "<leader>qc", function()
	require("quicker").collapse()
end, { silent = true, desc = "tool: Collapse quickfix context" })
