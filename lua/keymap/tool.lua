local helpers = require("keymap.helpers")
local set = vim.keymap.set

-- Plugin: snacks.nvim
set("n", "<C-p>", function()
	helpers.command_panel()
end, { silent = true, desc = "tool: Command panel" })

-- Plugin: edgy.nvim
set("n", "<C-n>", function()
	local edgy_config = require("edgy.config")
	local edgebar = edgy_config.layout and edgy_config.layout.left
	if edgebar then
		local has_visible = false
		for _, win in ipairs(edgebar.wins) do
			if vim.api.nvim_win_is_valid(win.win) then
				has_visible = true
				break
			end
		end
		if has_visible then
			require("edgy").close("left")
		else
			require("edgy").open("left")
		end
	else
		require("edgy").open("left")
	end
end, { silent = true, desc = "tool: Toggle sidebar" })

-- Plugin: sniprun
set("v", "<leader>r", "<Cmd>SnipRun<CR>", { silent = true, desc = "tool: Run code by range" })
set("n", "<leader>r", "<Cmd>%SnipRun<CR>", { silent = true, desc = "tool: Run code by file" })

-- Plugin: overseer.nvim
set("n", "<leader>or", "<Cmd>OverseerRun<CR>", { silent = true, desc = "tool: Overseer run" })
set("n", "<leader>ot", "<Cmd>OverseerToggle<CR>", { silent = true, desc = "tool: Overseer toggle" })
set("n", "<leader>oa", "<Cmd>OverseerQuickAction<CR>", { silent = true, desc = "tool: Overseer quick action" })
set("n", "<leader>oi", "<Cmd>OverseerInfo<CR>", { silent = true, desc = "tool: Overseer info" })

-- Plugin: markview.nvim
set("n", "<F1>", "<Cmd>Markview toggle<CR>", { silent = true, desc = "tool: Toggle markdown preview within nvim" })

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

-- Plugin: markdown-preview.nvim
set("n", "<F12>", "<Cmd>MarkdownPreviewToggle<CR>", { silent = true, desc = "tool: Preview markdown" })
