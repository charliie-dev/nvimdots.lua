local set = vim.keymap.set

-- Builtins: Buffer
set("n", "<leader>bn", "<Cmd>enew<CR>", { silent = true, desc = "buffer: New" })

-- Builtins: Terminal
set("t", "<C-w>h", "<Cmd>wincmd h<CR>", { silent = true, desc = "window: Focus left" })
set("t", "<C-w>l", "<Cmd>wincmd l<CR>", { silent = true, desc = "window: Focus right" })
set("t", "<C-w>j", "<Cmd>wincmd j<CR>", { silent = true, desc = "window: Focus down" })
set("t", "<C-w>k", "<Cmd>wincmd k<CR>", { silent = true, desc = "window: Focus up" })

-- Builtins: Tabpage
set("n", "tn", "<Cmd>tabnew<CR>", { silent = true, desc = "tab: Create a new tab" })
set("n", "tk", "<Cmd>tabnext<CR>", { silent = true, desc = "tab: Move to next tab" })
set("n", "tj", "<Cmd>tabprevious<CR>", { silent = true, desc = "tab: Move to previous tab" })
set("n", "to", "<Cmd>tabonly<CR>", { silent = true, desc = "tab: Only keep current tab" })

-- Snacks: bufdelete
set("n", "<A-q>", function()
	Snacks.bufdelete()
end, { silent = true, desc = "buffer: Close current" })

-- Plugin: bufferline.nvim
set("n", "<A-i>", "<Cmd>BufferLineCycleNext<CR>", { silent = true, desc = "buffer: Switch to next" })
set("n", "<A-o>", "<Cmd>BufferLineCyclePrev<CR>", { silent = true, desc = "buffer: Switch to prev" })
set("n", "<A-S-i>", "<Cmd>BufferLineMoveNext<CR>", { silent = true, desc = "buffer: Move current to next" })
set("n", "<A-S-o>", "<Cmd>BufferLineMovePrev<CR>", { silent = true, desc = "buffer: Move current to prev" })
set("n", "<leader>be", "<Cmd>BufferLineSortByExtension<CR>", { desc = "buffer: Sort by extension" })
set("n", "<leader>bd", "<Cmd>BufferLineSortByDirectory<CR>", { desc = "buffer: Sort by directory" })
set("n", "<A-1>", "<Cmd>BufferLineGoToBuffer 1<CR>", { silent = true, desc = "buffer: Goto buffer 1" })
set("n", "<A-2>", "<Cmd>BufferLineGoToBuffer 2<CR>", { silent = true, desc = "buffer: Goto buffer 2" })
set("n", "<A-3>", "<Cmd>BufferLineGoToBuffer 3<CR>", { silent = true, desc = "buffer: Goto buffer 3" })
set("n", "<A-4>", "<Cmd>BufferLineGoToBuffer 4<CR>", { silent = true, desc = "buffer: Goto buffer 4" })
set("n", "<A-5>", "<Cmd>BufferLineGoToBuffer 5<CR>", { silent = true, desc = "buffer: Goto buffer 5" })
set("n", "<A-6>", "<Cmd>BufferLineGoToBuffer 6<CR>", { silent = true, desc = "buffer: Goto buffer 6" })
set("n", "<A-7>", "<Cmd>BufferLineGoToBuffer 7<CR>", { silent = true, desc = "buffer: Goto buffer 7" })
set("n", "<A-8>", "<Cmd>BufferLineGoToBuffer 8<CR>", { silent = true, desc = "buffer: Goto buffer 8" })
set("n", "<A-9>", "<Cmd>BufferLineGoToBuffer 9<CR>", { silent = true, desc = "buffer: Goto buffer 9" })

-- Plugin: smart-splits.nvim
set("n", "<A-h>", "<Cmd>SmartResizeLeft<CR>", { silent = true, desc = "window: Resize -3 horizontally" })
set("n", "<A-j>", "<Cmd>SmartResizeDown<CR>", { silent = true, desc = "window: Resize -3 vertically" })
set("n", "<A-k>", "<Cmd>SmartResizeUp<CR>", { silent = true, desc = "window: Resize +3 vertically" })
set("n", "<A-l>", "<Cmd>SmartResizeRight<CR>", { silent = true, desc = "window: Resize +3 horizontally" })
set("n", "<C-h>", "<Cmd>SmartCursorMoveLeft<CR>", { silent = true, desc = "window: Focus left" })
set("n", "<C-j>", "<Cmd>SmartCursorMoveDown<CR>", { silent = true, desc = "window: Focus down" })
set("n", "<C-k>", "<Cmd>SmartCursorMoveUp<CR>", { silent = true, desc = "window: Focus up" })
set("n", "<C-l>", "<Cmd>SmartCursorMoveRight<CR>", { silent = true, desc = "window: Focus right" })
set("n", "<leader>Wh", "<Cmd>SmartSwapLeft<CR>", { silent = true, desc = "window: Move window leftward" })
set("n", "<leader>Wj", "<Cmd>SmartSwapDown<CR>", { silent = true, desc = "window: Move window downward" })
set("n", "<leader>Wk", "<Cmd>SmartSwapUp<CR>", { silent = true, desc = "window: Move window upward" })
set("n", "<leader>Wl", "<Cmd>SmartSwapRight<CR>", { silent = true, desc = "window: Move window rightward" })

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
	end, { buffer = bufnr, expr = true, desc = "git: Goto next hunk" })

	set("n", "[g", function()
		if vim.wo.diff then
			return "[g"
		end
		vim.schedule(function()
			gitsigns.nav_hunk("prev")
		end)
		return "<Ignore>"
	end, { buffer = bufnr, expr = true, desc = "git: Goto prev hunk" })

	set("n", "<leader>gs", function()
		gitsigns.stage_hunk()
	end, { buffer = bufnr, desc = "git: Toggle staging/unstaging of hunk" })

	set("v", "<leader>gs", function()
		gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end, { buffer = bufnr, desc = "git: Toggle staging/unstaging of selected hunk" })

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
