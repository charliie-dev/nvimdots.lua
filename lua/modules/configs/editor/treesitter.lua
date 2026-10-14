return function()
	require("modules.utils").load_plugin("nvim-treesitter", {})

	local function get_query(lang, name)
		local ok, query = pcall(vim.treesitter.query.get, lang, name)
		if ok then
			return query
		end
		vim.notify_once(string.format("Treesitter %s query for %s: %s", name, lang, query), vim.log.levels.WARN)
	end

	local function start(buf)
		local ft = vim.bo[buf].filetype
		if ft == "" then
			return
		end
		local lang = vim.treesitter.language.get_lang(ft) or ft
		-- External parsers need not appear in the installation list.
		local ok, added = pcall(vim.treesitter.language.add, lang)
		if not ok or not added then
			return
		end
		if get_query(lang, "indents") then
			vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
		if get_query(lang, "highlights") then
			pcall(vim.treesitter.start, buf, lang)
		end
	end

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
		pattern = "*",
		desc = "Start treesitter for installed parsers",
		callback = function(args)
			start(args.buf)
		end,
	})
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			start(buf)
		end
	end

	-- Install missing parser files. get_installed() without a type also counts leftover query
	-- directories, so a parser whose .so is gone was never reinstalled; check parser files only and
	-- force those. Buffers opened before the install finished get Treesitter once it completes.
	vim.schedule(function()
		local ts = require("nvim-treesitter")
		local installed = ts.get_installed("parsers")
		local missing = vim.tbl_filter(function(lang)
			return not vim.list_contains(installed, lang)
		end, vim.tbl_keys(require("core.settings").treesitter_deps))
		if #missing == 0 then
			return
		end
		table.sort(missing)
		ts.install(missing, { force = true }):await(function()
			vim.schedule(function()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(buf) and not vim.treesitter.highlighter.active[buf] then
						start(buf)
					end
				end
			end)
		end)
	end)
end
