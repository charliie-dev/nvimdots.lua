local status, treesitter = pcall(require, "nvim-treesitter.configs")
if not status then
	return
end

local autotag_status, autotag = pcall(require, "nvim-ts-autotag")
if not autotag_status then
	return
end

autotag.setup({})

treesitter.setup({
	highlight = {
		enable = true,
		disable = {},
		additional_vim_regex_highlighting = true,
	},
	indent = {
		enable = true,
		disable = {},
	},
	autopairs = {
		enable = true,
		disable = {},
	},
	autotag = {
		enable = true,
		disable = { "xml" },
	},
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
	rainbow = {
		enable = true,
		-- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = nil, -- Do not enable for files with more than n lines, int
		-- colors = {}, -- table of hex strings
		-- termcolors = {} -- table of colour name strings
	},
	ensure_installed = {
		"yaml",
		"toml",
		"markdown",
		"bash",
		"c",
		"cpp",
		"tsx",
		"php",
		"python",
		"html",
		"scss",
		"lua",
    "go",
    "rust",
    "vim",
    "zig",
	},
	sync_install = true,
	ignore_install = { "" },
})

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
