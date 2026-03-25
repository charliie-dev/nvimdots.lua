local helpers = require("keymap.helpers")
local set = vim.keymap.set

-- Plugin: dial
set({ "n", "v" }, "<leader>=", "<Plug>(dial-increment)", { desc = "edit: Increment" })
set({ "n", "v" }, "<leader>-", "<Plug>(dial-decrement)", { desc = "edit: Decrement" })

-- Plugin: vim-fugitive
set("n", "gps", "<Cmd>G push<CR>", { silent = true, desc = "git: Push" })
set("n", "gpl", "<Cmd>G pull<CR>", { silent = true, desc = "git: Pull" })
set("n", "<leader>gG", "<Cmd>Git<CR>", { silent = true, desc = "git: Open git-fugitive" })

-- Plugin: edgy
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
end, { silent = true, desc = "explorer: Toggle sidebar" })

-- Plugin: sniprun
set("v", "<leader>r", "<Cmd>SnipRun<CR>", { silent = true, desc = "tool: Run code by range" })
set("n", "<leader>r", "<Cmd>%SnipRun<CR>", { silent = true, desc = "tool: Run code by file" })

-- Plugin: overseer
set("n", "<leader>or", "<Cmd>OverseerRun<CR>", { silent = true, desc = "overseer: Run task" })
set("n", "<leader>ot", "<Cmd>OverseerToggle<CR>", { silent = true, desc = "overseer: Toggle task list" })
set("n", "<leader>oa", "<Cmd>OverseerQuickAction<CR>", { silent = true, desc = "overseer: Quick action" })
set("n", "<leader>oi", "<Cmd>OverseerInfo<CR>", { silent = true, desc = "overseer: Info" })

-- Snacks: terminal
set("t", "<Esc><Esc>", [[<C-\><C-n>]], { silent = true })
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

-- Snacks: lazygit
set("n", "lg", function()
	require("snacks").lazygit()
end, { silent = true, desc = "terminal: Toggle lazygit" })

-- Snacks: custom terminal helpers
set("n", "bt", function()
	helpers.toggle_float_term("btop", "btop")
end, { silent = true, desc = "terminal: Toggle btop" })
set("n", "lzd", function()
	helpers.toggle_float_term("lazydocker", "lazydocker")
end, { silent = true, desc = "terminal: Toggle lazydocker" })
set("n", "nvsmi", function()
	helpers.toggle_float_term("watch -n 1 nvidia-smi", "nvidia-smi")
end, { silent = true, desc = "terminal: Toggle nvidia-smi" })

-- Plugin: yazi.nvim
set("n", "yz", "<Cmd>Yazi<CR>", { silent = true, desc = "terminal: Toggle yazi" })

-- Plugin: trouble
set("n", "gt", "<Cmd>Trouble diagnostics toggle<CR>", { silent = true, desc = "lsp: Toggle trouble list" })
set(
	"n",
	"<leader>lw",
	"<Cmd>Trouble diagnostics toggle<CR>",
	{ silent = true, desc = "lsp: Show workspace diagnostics" }
)
set(
	"n",
	"<leader>lp",
	"<Cmd>Trouble project_diagnostics toggle<CR>",
	{ silent = true, desc = "lsp: Show project diagnostics" }
)
set(
	"n",
	"<leader>ld",
	"<Cmd>Trouble diagnostics toggle filter.buf=0<CR>",
	{ silent = true, desc = "lsp: Show document diagnostics" }
)

-- Plugin: snacks.picker
set("n", "<C-p>", function()
	helpers.command_panel()
end, { silent = true, desc = "tool: Toggle command panel" })

-- File
set("n", "<leader>ff", function()
	require("snacks").picker.smart()
end, { silent = true, desc = "tool: Find files (smart)" })
set("n", "<leader>fb", function()
	require("snacks").picker.buffers()
end, { silent = true, desc = "tool: Find buffers" })

-- Pattern
set("n", "<leader>fp", function()
	require("snacks").picker.grep()
end, { silent = true, desc = "tool: Live grep" })
set("v", "<leader>fs", function()
	require("snacks").picker.grep_word()
end, { silent = true, desc = "tool: Grep visual selection" })

-- Git
set("n", "<leader>fgb", function()
	require("snacks").picker.git_branches()
end, { silent = true, desc = "tool: Git branches" })
set("n", "<leader>fgc", function()
	require("snacks").picker.git_log()
end, { silent = true, desc = "tool: Git commits" })
set("n", "<leader>fgs", function()
	require("snacks").picker.git_status()
end, { silent = true, desc = "tool: Git status" })
set("n", "<leader>fgS", function()
	require("advanced_git_search.snacks.pickers").search_log_content()
end, { silent = true, desc = "tool: Git search log content" })
set("n", "<leader>fgd", function()
	require("advanced_git_search.snacks.pickers").diff_commit_file()
end, { silent = true, desc = "tool: Git diff current file" })

-- Dossier
set("n", "<leader>fds", function()
	helpers.persisted_sessions()
end, { silent = true, desc = "tool: Find sessions" })
set("n", "<leader>fdp", function()
	require("snacks").picker.projects()
end, { silent = true, desc = "tool: Find projects" })

-- Misc
set("n", "<leader>fmc", function()
	require("snacks").picker.colorschemes()
end, { silent = true, desc = "tool: Colorschemes" })
set("n", "<leader>fmu", function()
	require("snacks").picker.undo()
end, { silent = true, desc = "tool: Undo history" })

set("n", "<leader>fr", function()
	require("snacks").picker.resume()
end, { silent = true, desc = "tool: Resume last search" })

-- Plugin: dap
set("n", "<F6>", function()
	require("dap").continue()
end, { silent = true, desc = "debug: Run/Continue" })
set("n", "<F7>", function()
	require("dap").terminate()
end, { silent = true, desc = "debug: Stop" })
set("n", "<F8>", function()
	require("dap").toggle_breakpoint()
end, { silent = true, desc = "debug: Toggle breakpoint" })
set("n", "<F9>", function()
	require("dap").step_into()
end, { silent = true, desc = "debug: Step into" })
set("n", "<F10>", function()
	require("dap").step_out()
end, { silent = true, desc = "debug: Step out" })
set("n", "<F11>", function()
	require("dap").step_over()
end, { silent = true, desc = "debug: Step over" })
set("n", "<leader>db", function()
	require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { silent = true, desc = "debug: Set breakpoint with condition" })
set("n", "<leader>dc", function()
	require("dap").run_to_cursor()
end, { silent = true, desc = "debug: Run to cursor" })
set("n", "<leader>dl", function()
	require("dap").run_last()
end, { silent = true, desc = "debug: Run last" })
set("n", "<leader>do", function()
	require("dap").repl.open()
end, { silent = true, desc = "debug: Open REPL" })
