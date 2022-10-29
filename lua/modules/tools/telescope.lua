local cmd = vim.api.nvim_command
cmd([[packadd sqlite.lua]])
cmd([[packadd telescope-fzf-native.nvim]])
cmd([[packadd telescope-project.nvim]])
cmd([[packadd telescope-frecency.nvim]])
cmd([[packadd telescope-zoxide]])
cmd([[packadd telescope-env.nvim]])
cmd([[packadd dir-telescope.nvim]])

local icons = { ui = require("modules.ui.icons").get("ui", true) }

local actions = require("telescope.actions.set")
local fixfolds = {
	hidden = true,
	attach_mappings = function(_)
		actions.select:enhance({
			post = function()
				vim.api.nvim_command(":normal! zx")
			end,
		})
		return true
	end,
}

require("telescope").setup({
	defaults = {
		initial_mode = "insert",
		prompt_prefix = " " .. icons.ui.Telescope,
		selection_caret = icons.ui.ChevronRight,
		entry_prefix = " ",
		scroll_strategy = "limit",
		results_title = false,
		borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		layout_strategy = "horizontal",
		path_display = { "smart" }, -- absolute
		dynamic_preview_title = true,
		file_ignore_patterns = {
			".git/",
			".cache",
			"%.class",
			"%.pdf",
			"%.mkv",
			"%.mp4",
			"%.zip",
			"node_modules/",
			"target/",
			"docs/",
			".settings/",
		},
		layout_config = {
			prompt_position = "bottom",
			horizontal = {
				preview_width = 0.5,
			},
		},
		file_previewer = require("telescope.previewers").vim_buffer_cat.new,
		grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
		qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
		file_sorter = require("telescope.sorters").get_fuzzy_file,
		generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
	},
	extensions = {
		-- conda = {
		-- 	home = "$HOME/tools/anaconda",
		-- },
		fzf = {
			fuzzy = false,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
		frecency = {
			show_scores = true,
			show_unindexed = true,
			ignore_patterns = { "*.git/*", "*/tmp/*" },
			disable_devicons = false,
			workspaces = {
				-- ["conf"] = "/home/my_username/.config",
				-- ["data"] = "/home/my_username/.local/share",
				-- ["project"] = "/home/my_username/projects",
				-- ["wiki"] = "/home/my_username/wiki"
			},
		},
		-- file_browser = {
		-- 	theme = "ivy",
		-- 	-- disables netrw and use telescope-file-browser in its place
		-- 	hijack_netrw = false,
		-- },
		project = {
			base_dirs = {
				{ "~", max_depth = 1 },
				{ "~/Workspace", max_depth = 1 },
			},
			hidden_files = true, -- default: false
			theme = "dropdown",
			order_by = "asc",
		},
	},
	pickers = {
		buffers = fixfolds,
		find_files = fixfolds,
		git_files = fixfolds,
		grep_string = fixfolds,
		live_grep = fixfolds,
		oldfiles = fixfolds,
	},
})

-- zoxide config
local z_utils = require("telescope._extensions.zoxide.utils")
local builtin = require("telescope.builtin")

require("telescope._extensions.zoxide.config").setup({
	prompt_title = "[ Zoxide List ]",

	-- Zoxide list command with score
	list_command = "zoxide query -ls",
	mappings = {
		default = {
			action = function(selection)
				vim.api.nvim_command("cd " .. selection.path)
			end,
			after_action = function(selection)
				print("Directory changed to " .. selection.path)
			end,
		},
		["<C-s>"] = { action = z_utils.create_basic_command("split") },
		["<C-v>"] = { action = z_utils.create_basic_command("vsplit") },
		["<C-e>"] = { action = z_utils.create_basic_command("edit") },
		["<C-b>"] = {
			keepinsert = true,
			action = function(selection)
				builtin.file_browser({ cwd = selection.path })
			end,
		},
		["<C-f>"] = {
			keepinsert = true,
			action = function(selection)
				builtin.find_files({ cwd = selection.path })
			end,
		},
	},
})

-- dir-telescope config
-- this plugins are useful for big project, your can select a dir first and search within the dir,
--   instead of searching the whole project.
require("dir-telescope").setup({
	hidden = true,
	respect_gitignore = true,
})
-- INFO: <C-q> will save your queries in a quickfix list. this is the default binding for telescope.nvim

-- plugins should load after setup function
-- require("telescope").load_extension("dap")
require("telescope").load_extension("env")
require("telescope").load_extension("frecency")
require("telescope").load_extension("fzf")
require("telescope").load_extension("project")
require("telescope").load_extension("zoxide")
require("telescope").load_extension("dir")
require("telescope").load_extension("notify")
-- require("telescope").load_extension("harpoon")
require("telescope").load_extension("neoclip")
