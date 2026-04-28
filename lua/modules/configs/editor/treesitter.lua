return vim.schedule_wrap(function()
	vim.api.nvim_set_option_value("indentexpr", "v:lua.require'nvim-treesitter'.indentexpr()", {})

	require("modules.utils").load_plugin("nvim-treesitter", {})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "*",
		desc = "Start treesitter for installed parsers",
		callback = function(args)
			local ft = vim.bo[args.buf].filetype
			local lang = vim.treesitter.language.get_lang(ft) or ft
			if require("core.settings").treesitter_deps[lang] then
				pcall(vim.treesitter.start, args.buf, lang)
			end
		end,
	})
	-- require("modules.utils").load_plugin("nvim-treesitter", {
	-- 	ensure_installed = vim.tbl_keys(require("core.settings").treesitter_deps),
	-- 	playground = {
	-- 		enable = true,
	-- 		disable = {},
	-- 		updatetime = 50, -- Debounced time for highlighting nodes in the playground from source code
	-- 		persist_queries = true, -- Whether the query persists across vim sessions
	-- 	},
	-- 	highlight = {
	-- 		enable = true,
	-- 		disable = function(ft)
	-- 			return vim.tbl_contains({ "gitcommit" }, ft)
	-- 		end,
	-- 		additional_vim_regex_highlighting = false,
	-- 	},
	-- 	indent = { enable = true },
	-- 	matchup = { enable = true },
	-- }, false, require("nvim-treesitter.configs").setup)

	local parsers = vim.tbl_keys(require("core.settings").treesitter_deps)
	table.sort(parsers)
	require("nvim-treesitter").install(parsers)
	-- require("nvim-treesitter.install").prefer_git = true
	-- if use_ssh then
	-- 	local parsers = require("nvim-treesitter.parsers").get_parser_configs()
	-- 	for _, parser in pairs(parsers) do
	-- 		parser.install_info.url = parser.install_info.url:gsub("https://github.com/", "git@github.com:")
	-- 	end
	-- end
end)
