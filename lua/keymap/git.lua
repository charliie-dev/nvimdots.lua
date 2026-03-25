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

	set("n", "]g", function()
		if vim.wo.diff then
			return "]g"
		end
		vim.schedule(function()
			gitsigns.nav_hunk("next")
		end)
		return "<Ignore>"
	end, { buffer = bufnr, expr = true, desc = "git: Next hunk" })

	set("n", "[g", function()
		if vim.wo.diff then
			return "[g"
		end
		vim.schedule(function()
			gitsigns.nav_hunk("prev")
		end)
		return "<Ignore>"
	end, { buffer = bufnr, expr = true, desc = "git: Prev hunk" })

	set("n", "<leader>gs", function()
		gitsigns.stage_hunk()
	end, { buffer = bufnr, desc = "git: Stage hunk" })

	set("v", "<leader>gs", function()
		gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end, { buffer = bufnr, desc = "git: Stage hunk" })

	set("n", "<leader>gr", function()
		gitsigns.reset_hunk()
	end, { buffer = bufnr, desc = "git: Reset hunk" })

	set("v", "<leader>gr", function()
		gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end, { buffer = bufnr, desc = "git: Reset hunk" })

	set("n", "<leader>gR", function()
		gitsigns.reset_buffer()
	end, { buffer = bufnr, desc = "git: Reset buffer" })

	set("n", "<leader>gp", function()
		gitsigns.preview_hunk()
	end, { buffer = bufnr, desc = "git: Preview hunk" })

	set("n", "<leader>gb", function()
		gitsigns.blame_line({ full = true })
	end, { buffer = bufnr, desc = "git: Blame line" })

	-- Text objects
	set({ "o", "x" }, "ih", function()
		gitsigns.select_hunk()
	end, { buffer = bufnr })
end

return M
