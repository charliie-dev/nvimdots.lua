require("hlslens").setup({
	auto_enable = true,
	enable_incsearch = true,
	override_lens = function(render, posList, nearest, idx, relIdx)
		local sfw = vim.v.searchforward == 1
		local indicator, text, chunks
		local absRelIdx = math.abs(relIdx)
		if absRelIdx > 1 then
			indicator = ("%d%s"):format(absRelIdx, sfw ~= (relIdx > 1) and "▲" or "▼")
		elseif absRelIdx == 1 then
			indicator = sfw ~= (relIdx == 1) and "▲" or "▼"
		else
			indicator = ""
		end

		local lnum, col = posList[idx][1], posList[idx][1]
		if nearest then
			local cnt = #posList
			if indicator ~= "" then
				text = ("[%s %d/%d]"):format(indicator, idx, cnt)
			else
				text = ("[%d/%d]"):format(idx, cnt)
			end
			chunks = { { " ", "Ignore" }, { text, "HlSearchLensNear" } }
		else
			text = ("[%s %d]"):format(indicator, idx)
			chunks = { { " ", "Ignore" }, { text, "HlSearchLens" } }
		end
		render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
	end,
	build_position_cb = function(plist, _, _, _)
		require("scrollbar.handlers.search").handler.show(plist.start_pos)
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "CmdlineLeave",
	callback = function()
		vim.schedule(function()
			require("scrollbar.handlers.search").handler.hide()
		end)
	end,
})
