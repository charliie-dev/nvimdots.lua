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
end
