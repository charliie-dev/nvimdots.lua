return function()
	-- Bqf previews an unmodified loaded buffer by reading its file from disk. An acwrite buffer
	-- (sops.nvim, vim-suda) holds something else than its file, such as decrypted text, so preview
	-- the buffer itself, as Quicker's context lines do
	local utils = require("bqf.utils")
	local transfer_buf = utils.transferBuf
	utils.transferBuf = function(from, to)
		if not (vim.api.nvim_buf_is_loaded(from) and vim.bo[from].buftype == "acwrite") then
			return transfer_buf(from, to)
		end
		vim.api.nvim_buf_set_lines(to, 0, -1, false, vim.api.nvim_buf_get_lines(from, 0, -1, false))
		vim.bo[to].modified = false
	end

	-- Bqf runs `silent! au! BqfFilterFzf * <buffer>` whenever a quickfix window closes, but only
	-- creates that group the first time the fzf filter runs; until then each close sets v:errmsg to
	-- E216. An empty group of that name lets the command find it.
	vim.api.nvim_create_augroup("BqfFilterFzf", { clear = false })

	require("modules.utils").load_plugin("bqf", {
		preview = {
			border = "single",
			wrap = true,
			winblend = 0,
		},
	})
end
