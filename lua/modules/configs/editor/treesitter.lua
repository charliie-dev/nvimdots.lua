return vim.schedule_wrap(function()
	vim.api.nvim_set_option_value("indentexpr", "v:lua.require'nvim-treesitter'.indentexpr()", {})

	require("modules.utils").load_plugin("nvim-treesitter", {})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "*",
		desc = "Start treesitter for installed parsers",
		callback = function(args)
			local ft = vim.bo[args.buf].filetype
			local lang = vim.treesitter.language.get_lang(ft) or ft
			-- Gate on what is actually available rather than on `treesitter_deps`, which only
			-- drives install()/update(): parsers shipped by external grammars (d2, ghostty)
			-- are never listed there, and parsers dropped upstream keep their stale .so.
			local ok, added = pcall(vim.treesitter.language.add, lang)
			if not ok or added == false then
				return
			end
			if not vim.treesitter.query.get(lang, "highlights") then
				return
			end
			pcall(vim.treesitter.start, args.buf, lang)
		end,
	})
	local parsers = vim.tbl_keys(require("core.settings").treesitter_deps)
	table.sort(parsers)
	require("nvim-treesitter").install(parsers)
end)
