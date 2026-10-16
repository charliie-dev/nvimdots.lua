local set = vim.keymap.set

-- Plugin: diffview.nvim
set("n", "<leader>gd", "<Cmd>DiffviewOpen<CR>", { silent = true, desc = "git: Open diff" })
set("n", "<leader>gD", "<Cmd>DiffviewClose<CR>", { silent = true, desc = "git: Close diff" })

-- Plugin: snacks.nvim
set("n", "<leader>gB", function()
	require("snacks").picker.git_branches()
end, { silent = true, desc = "git: Branches" })
set("n", "<leader>gc", function()
	require("snacks").picker.git_log()
end, { silent = true, desc = "git: Commits" })
set("n", "<leader>gS", function()
	require("snacks").picker.git_status()
end, { silent = true, desc = "git: Status" })
-- Plugin: advanced-git-search.nvim
set("n", "<leader>gl", function()
	require("advanced_git_search.snacks.pickers").search_log_content()
end, { silent = true, desc = "git: Search log content" })
set("n", "<leader>gf", function()
	require("advanced_git_search.snacks.pickers").diff_commit_file()
end, { silent = true, desc = "git: Diff current file" })

local M = {}

function M.gitsigns(bufnr)
	local gitsigns = require("gitsigns")

	-- Jump synchronously, in the window the key was pressed in. A scheduled jump ran after the keys
	-- that followed it (a macro's <C-w>w), and the greedy hunk search awaits a threaded diff before
	-- reading the current window; greedy = false reuses the cached hunks instead.
	local function nav(direction, diff_key)
		return function()
			if vim.wo.diff then
				vim.cmd.normal({ vim.v.count1 .. diff_key, bang = true })
			else
				gitsigns.nav_hunk(direction, { greedy = false })
			end
		end
	end
	set("n", "]g", nav("next", "]c"), { buf = bufnr, desc = "git: Next hunk" })
	set("n", "[g", nav("prev", "[c"), { buf = bufnr, desc = "git: Prev hunk" })

	set("n", "<leader>gs", function()
		gitsigns.stage_hunk()
	end, { buf = bufnr, desc = "git: Stage hunk" })

	set("v", "<leader>gs", function()
		gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end, { buf = bufnr, desc = "git: Stage hunk" })

	set("n", "<leader>gr", function()
		gitsigns.reset_hunk()
	end, { buf = bufnr, desc = "git: Reset hunk" })

	set("v", "<leader>gr", function()
		gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end, { buf = bufnr, desc = "git: Reset hunk" })

	set("n", "<leader>gR", function()
		gitsigns.reset_buffer()
	end, { buf = bufnr, desc = "git: Reset buffer" })

	set("n", "<leader>gp", function()
		gitsigns.preview_hunk()
	end, { buf = bufnr, desc = "git: Preview hunk" })

	set("n", "<leader>gb", function()
		gitsigns.blame_line({ full = true })
	end, { buf = bufnr, desc = "git: Blame line" })

	-- Text objects
	set({ "o", "x" }, "ih", function()
		gitsigns.select_hunk()
	end, { buf = bufnr })
end

return M
