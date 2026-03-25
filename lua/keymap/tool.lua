local helpers = require("keymap.helpers")
local set = vim.keymap.set

-- Command panel
set("n", "<C-p>", function()
	helpers.command_panel()
end, { silent = true, desc = "tool: Command panel" })

-- Sidebar (edgy)
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

-- SnipRun
set("v", "<leader>r", "<Cmd>SnipRun<CR>", { silent = true, desc = "tool: Run code by range" })
set("n", "<leader>r", "<Cmd>%SnipRun<CR>", { silent = true, desc = "tool: Run code by file" })

-- Overseer
set("n", "<leader>or", "<Cmd>OverseerRun<CR>", { silent = true, desc = "tool: Overseer run" })
set("n", "<leader>ot", "<Cmd>OverseerToggle<CR>", { silent = true, desc = "tool: Overseer toggle" })
set("n", "<leader>oa", "<Cmd>OverseerQuickAction<CR>", { silent = true, desc = "tool: Overseer quick action" })
set("n", "<leader>oi", "<Cmd>OverseerInfo<CR>", { silent = true, desc = "tool: Overseer info" })

-- Trouble (diagnostics quick access)
set("n", "gt", "<Cmd>Trouble diagnostics toggle<CR>", { silent = true, desc = "lsp: Toggle trouble list" })
set(
	"n",
	"<leader>lw",
	"<Cmd>Trouble diagnostics toggle<CR>",
	{ silent = true, desc = "lsp: Workspace diagnostics" }
)
set(
	"n",
	"<leader>lp",
	"<Cmd>Trouble project_diagnostics toggle<CR>",
	{ silent = true, desc = "lsp: Project diagnostics" }
)
set(
	"n",
	"<leader>ld",
	"<Cmd>Trouble diagnostics toggle filter.buf=0<CR>",
	{ silent = true, desc = "lsp: Document diagnostics" }
)

-- Markview
set("n", "<F1>", "<Cmd>Markview toggle<CR>", { silent = true, desc = "tool: Toggle markdown preview within nvim" })

-- MarkdownPreview
set("n", "<F12>", "<Cmd>MarkdownPreviewToggle<CR>", { silent = true, desc = "tool: Preview markdown" })
