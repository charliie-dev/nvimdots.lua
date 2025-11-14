return vim.schedule_wrap(function()
	-- local use_ssh = require("core.settings").use_ssh
	-- vim.api.nvim_set_option_value("foldmethod", "expr", {})
	-- vim.api.nvim_set_option_value("foldexpr", "nvim_treesitter#foldexpr()", {})
	-- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	vim.api.nvim_set_option_value("indentexpr", "v:lua.require'nvim-treesitter'.indentexpr()", {})

	require("modules.utils").load_plugin("nvim-treesitter")
	-- require("modules.utils").load_plugin("nvim-treesitter", {
	-- 	ensure_installed = require("core.settings").treesitter_deps,
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

	require("nvim-treesitter").install(require("core.settings").treesitter_deps)
	-- require("nvim-treesitter.install").prefer_git = true
	-- if use_ssh then
	-- 	local parsers = require("nvim-treesitter.parsers").get_parser_configs()
	-- 	for _, parser in pairs(parsers) do
	-- 		parser.install_info.url = parser.install_info.url:gsub("https://github.com/", "git@github.com:")
	-- 	end
	-- end
end)
