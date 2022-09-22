local status, ntree = pcall(require, "nvim-tree")
if not status then
	return
end

ntree.setup({
	auto_reload_on_write = true,
	create_in_closed_folder = true,
	disable_netrw = false,
	hijack_cursor = false,
	hijack_netrw = false,
	hijack_unnamed_buffer_when_opening = false,
	ignore_buffer_on_setup = false,
	open_on_setup = false,
	open_on_setup_file = false,
	open_on_tab = false,
	sort_by = "name",
	update_cwd = true,
	reload_on_bufenter = false,
	respect_buf_cwd = false,
	view = {
		adaptive_size = false,
		centralize_selection = false,
		width = 32,
		-- height = 32,
		hide_root_folder = false,
		side = "left",
		preserve_window_proportions = false,
		number = false,
		relativenumber = false,
		signcolumn = "yes",
		mappings = {
			custom_only = false,
			list = {
				-- user mappings go here
				-- { key = { "l", "<CR>", "o" }, cb = tree_cb "edit" },
				-- { key = "h", cb = tree_cb "close_node" },
				-- { key = "v", cb = tree_cb "vsplit" },
			},
		},
	},
	renderer = {
		add_trailing = true,
		group_empty = false,
		highlight_git = true,
		full_name = false,
		highlight_opened_files = "name",
		root_folder_modifier = ":~",
		indent_markers = {
			enable = true,
			icons = {
				corner = "└ ",
				edge = "│ ",
				item = "│ ",
				none = "  ",
			},
		},
		icons = {
			webdev_colors = true,
			git_placement = "before",
			padding = " ",
			symlink_arrow = " ➛ ",
			show = {
				file = true,
				folder = true,
				folder_arrow = true,
				git = true,
			},
			glyphs = {
				default = "",
				symlink = "",
				folder = {
					arrow_closed = "",
					arrow_open = "",
					default = "",
					open = "",
					empty = "",
					empty_open = "",
					symlink = "",
					symlink_open = "",
				},
				git = {
					unstaged = "M",
					staged = "S",
					unmerged = "",
					renamed = "➜",
					untracked = "U",
					deleted = "",
					ignored = "◌",
				},
			},
		},
		special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
	},
	hijack_directories = {
		enable = true,
		auto_open = false,
	},
	update_focused_file = {
    update_root = true,
		enable = false,
		ignore_list = { "help" },
	},
	ignore_ft_on_setup = {
		"startify",
		"dashboard",
		"alpha",
	},
	-- system_open = {
	--   cmd = "",
	--   args = {},
	-- },
	diagnostics = {
		enable = true,
		show_on_dirs = true,
		icons = {
			hint = "",
			info = "",
			warning = "",
			error = "",
		},
	},
	filters = {
	  dotfiles = false,
	  custom = { ".git" },
	  exclude = {},
	},
	git = {
		enable = true,
		ignore = true,
		timeout = 400,
	},
  actions = {
    use_system_clipboard = true,
    change_dir = {
      enable = true,
      global = false,
      restrict_above_cwd = false,
    },
    expand_all = {
      max_folder_discovery = 300,
    },
    open_file = {
      quit_on_open = false,
      resize_window = true,
      window_picker = {
        enable = true,
        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
        exclude = {
          filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
          buftype = { "nofile", "terminal", "help" },
        },
      },
    },
    remove_file = {
      close_window = true,
    },
  },
	trash = {
		cmd = "gio trash",
		require_confirm = true,
	},
	live_filter = {
		prefix = "[FILTER]: ",
		always_show_folders = true,
	},
})
