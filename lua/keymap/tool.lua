local vim_path = require("core.global").vim_path
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

-- Plugin: telescope
set("n", "<C-p>", function()
	if require("core.settings").search_backend == "fzf" then
		local ok, tconf = pcall(require, "telescope.config")
		local prompt_position = ok and tconf.values.layout_config.horizontal.prompt_position or "top"
		require("fzf-lua").keymaps({
			fzf_opts = { ["--layout"] = prompt_position == "top" and "reverse" or "default" },
		})
	else
		helpers.command_panel()
	end
end, { silent = true, desc = "tool: Toggle command panel" })
set("n", "<leader>fc", function()
	if require("core.settings").search_backend == "fzf" then
		local ok, themes = pcall(require, "telescope.themes")
		if ok then
			helpers.telescope_collections(themes.get_dropdown({}))
		else
			helpers.telescope_collections({})
		end
	else
		helpers.telescope_collections(require("telescope.themes").get_dropdown({}))
	end
end, { silent = true, desc = "tool: Open Telescope (collections)" })
set("n", "<leader>ff", function()
	require("search").open({ collection = "file" })
end, { silent = true, desc = "tool: Find files" })
set("n", "<leader>fp", function()
	require("search").open({ collection = "pattern" })
end, { silent = true, desc = "tool: Find patterns" })
set("v", "<leader>fs", function()
	local is_config = vim.uv.cwd() == vim_path
	if require("core.settings").search_backend == "fzf" then
		require("fzf-lua").grep_project({
			search = require("fzf-lua.utils").get_visual_selection(),
			rg_opts = "--column --line-number --no-heading --color=always --smart-case"
				.. (is_config and " --no-ignore --hidden --glob '!.git/*'" or ""),
		})
	else
		require("telescope-live-grep-args.shortcuts").grep_visual_selection(
			is_config and { additional_args = { "--no-ignore" } } or {}
		)
	end
end, { silent = true, desc = "tool: Find word under cursor" })
set("n", "<leader>fg", function()
	require("search").open({ collection = "git" })
end, { silent = true, desc = "tool: Locate Git objects" })
set("n", "<leader>fd", function()
	require("search").open({ collection = "dossier" })
end, { silent = true, desc = "tool: Retrieve dossiers" })
set("n", "<leader>fm", function()
	require("search").open({ collection = "misc" })
end, { silent = true, desc = "tool: Miscellaneous" })
set("n", "<leader>fr", function()
	if require("core.settings").search_backend == "fzf" then
		require("fzf-lua").resume()
	else
		require("telescope.builtin").resume()
	end
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
