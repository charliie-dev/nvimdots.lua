return function()
	local resolver = require("core.global").is_mac and "grealpath" or "realpath"

	-- Yazi force-wipes the buffer of a file it deleted or trashed, unsaved changes included. Keep a
	-- modified buffer and say so, so its text can still be saved; close the others like the default
	-- (snacks bufdelete, which keeps the window layout).
	local function bufdelete(bufnr)
		if vim.bo[bufnr].modified then
			local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")
			vim.notify(
				("%s was deleted but has unsaved changes, so its buffer was kept. :w restores the file."):format(name),
				vim.log.levels.WARN,
				{ title = "Yazi" }
			)
			return
		end
		require("snacks").bufdelete.delete({ buf = bufnr, force = true, wipe = true })
	end

	require("modules.utils").load_plugin("yazi", {
		integrations = {
			-- Upstream defaults to telescope, which this config no longer ships.
			grep_in_directory = "snacks.picker",
			grep_in_selected_files = "snacks.picker",
			bufdelete_implementation = bufdelete,
		},
		keymaps = vim.fn.executable(resolver) == 0 and {
			copy_relative_path_to_selected_files = false,
		} or nil,
	})

	-- Yazi renames a buffer and then reloads it with :edit!, which drops unsaved changes; put them
	-- back once that reload ran. When the new name is already open in another buffer, Yazi closes
	-- this one (bufdelete above keeps it if modified) and reloads it from the old path, which is
	-- gone by then, emptying it. Leave such a buffer alone under its old name instead.
	local utils = require("yazi.utils")
	local rename_or_close_buffer = utils.rename_or_close_buffer
	utils.rename_or_close_buffer = function(config, instruction)
		local bufnr = instruction.bufnr
		if not (vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].modified) then
			return rename_or_close_buffer(config, instruction)
		end
		local new = instruction.path.filename
		if utils.is_buffer_open(new) then
			vim.notify(
				("%s was renamed to %s, which is already open, so this buffer keeps its unsaved changes under the old name."):format(
					vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:."),
					vim.fn.fnamemodify(new, ":~:.")
				),
				vim.log.levels.WARN,
				{ title = "Yazi" }
			)
			return
		end
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local cursors = {}
		for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
			cursors[win] = vim.api.nvim_win_get_cursor(win)
		end
		rename_or_close_buffer(config, instruction)
		-- Queued after Yazi's own scheduled :edit!
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
			for win, cursor in pairs(cursors) do
				if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
					pcall(vim.api.nvim_win_set_cursor, win, cursor)
				end
			end
		end)
	end
end
