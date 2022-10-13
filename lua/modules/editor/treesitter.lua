vim.api.nvim_set_option_value("foldmethod", "expr", {})
vim.api.nvim_set_option_value("foldexpr", "nvim_treesitter#foldexpr()", {})

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"bash",
		"c",
		"cpp",
		"css",
		"go",
		"gomod",
		"html",
		"javascript",
		"json",
		"latex",
		"lua",
		"make",
		"python",
		"rust",
		"toml",
		"tsx",
		"typescript",
		"typescript",
		"vim",
		"yaml",
	},
	sync_install = true,
	ignore_install = { "markdown" },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = ",s",
			node_incremental = ",s",
			scope_incremental = ",n",
			node_decremental = ",n",
		},
	},
	playground = {
		enable = true,
		disable = {},
		updatetime = 50, -- Debounced time for highlighting nodes in the playground from source code
		persist_queries = true, -- Whether the query persists across vim sessions
	},
	highlight = {
		enable = true,
		disable = { "help", "markdown" },
		additional_vim_regex_highlighting = true,
	},
	textobjects = {
		select = {
			enable = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]["] = "@function.outer",
				["]m"] = "@class.outer",
			},
			goto_next_end = {
				["]]"] = "@function.outer",
				["]M"] = "@class.outer",
			},
			goto_previous_start = {
				["[["] = "@function.outer",
				["[m"] = "@class.outer",
			},
			goto_previous_end = {
				["[]"] = "@function.outer",
				["[M"] = "@class.outer",
			},
		},
	},
	rainbow = {
		enable = true,
		extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
		max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
	},
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
	matchup = { enable = true },
	-- markid = { enable = true },
	refactor = {
		highlight_definitions = {
			enable = true,
			-- Set to false if you have an `updatetime` of ~100.
			clear_on_cursor_move = true,
		},
		highlight_current_scope = { enable = true },
		smart_rename = {
			enable = true,
			keymaps = {
				smart_rename = "grr",
			},
		},
	},
})

require("nvim-treesitter.install").prefer_git = true
local parsers = require("nvim-treesitter.parsers").get_parser_configs()
for _, p in pairs(parsers) do
	p.install_info.url = p.install_info.url:gsub("https://github.com/", "git@github.com:")
end

-- local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
-- parser_config.bash.filetype_to_parsername = { "bash", "sh", "zsh" }
-- print(vim.inspect(parser_config.bash))

-- local ft_to_lang = require("nvim-treesitter.parsers").ft_to_lang
-- require("nvim-treesitter.parsers").ft_to_lang = function(ft)
-- 	if ft == "sh" then
-- 		return "bash"
-- 	end
-- 	return ft_to_lang(ft)
-- end

-- local ft_to_parsername = require("nvim-treesitter.parsers").filetype_to_parsername
-- print(vim.inspect(ft_to_parsername))
