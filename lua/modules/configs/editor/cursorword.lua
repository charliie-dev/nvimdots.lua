return function()
	require("modules.utils").load_plugin("mini.cursorword", {
		-- Delay (in ms) between when cursor moved and when highlighting appeared
		delay = 200,
	})
	require("modules.utils").gen_cursorword_hl()

	-- Registered after mini.cursorword's own ColorScheme handler, which would otherwise restore its
	-- defaults (an empty MiniCursorwordCurrent counts as undefined)
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("CursorwordHl", { clear = true }),
		callback = function()
			require("modules.utils").gen_cursorword_hl()
		end,
	})
end
