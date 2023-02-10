return function()
	local icons = { ui = require("modules.utils.icons").get("ui", true) }
	local lga_actions = require("telescope-live-grep-args.actions")

	require("telescope").setup({
		defaults = {
			initial_mode = "insert",
			prompt_prefix = " " .. icons.ui.Telescope .. " ",
			selection_caret = icons.ui.ChevronRight,
			entry_prefix = " ",
			scroll_strategy = "limit",
			results_title = false,
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
			},
			layout_config = {
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
		pickers = {
			keymaps = {
				theme = "dropdown",
			},
		},
		extensions = {
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
			live_grep_args = {
				auto_quoting = true, -- enable/disable auto-quoting
				-- define mappings, e.g.
				mappings = { -- extend mappings
					i = {
						["<C-k>"] = lga_actions.quote_prompt(),
						["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
					},
				},
			},
			undo = {
				use_delta = true,
				side_by_side = true,
				layout_strategy = "vertical",
				layout_config = {
					preview_height = 0.7,
				},
				mappings = {
					i = {
						["<cr>"] = require("telescope-undo.actions").yank_additions,
						["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
						["<C-cr>"] = require("telescope-undo.actions").restore,
					},
				},
			},
		},
	})

	-- plugins should load after setup function
	require("telescope").load_extension("env")
	require("telescope").load_extension("frecency")
	require("telescope").load_extension("fzf")
	require("telescope").load_extension("live_grep_args")
	require("telescope").load_extension("neoclip")
	require("telescope").load_extension("notify")
	require("telescope").load_extension("projects")
	require("telescope").load_extension("undo")

	function _Command_panel()
		local opts = {
			lhs_filter = function(lhs)
				return not string.find(lhs, "Þ")
			end,
			layout_config = {
				width = 0.6,
				height = 0.6,
				prompt_position = "top",
			},
		}
		require("telescope.builtin").keymaps(opts)
	end
end
