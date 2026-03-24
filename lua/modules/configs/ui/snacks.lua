return function()
	local icons = {
		diagnostics = require("modules.utils.icons").get("diagnostics"),
		documents = require("modules.utils.icons").get("documents", true),
		git = require("modules.utils.icons").get("git", true),
		ui = require("modules.utils.icons").get("ui", true),
		misc = require("modules.utils.icons").get("misc", true),
	}

	local use_fzf = require("core.settings").search_backend == "fzf"

	require("modules.utils").load_plugin("snacks", {
		bigfile = { enabled = true },
		bufdelete = { enabled = true },
		dashboard = {
			enabled = true,
			preset = {
				header = table.concat(require("core.settings").dashboard_image, "\n"),
				keys = {
					{
						icon = icons.documents.Files,
						key = "f",
						desc = "Find file",
						action = use_fzf and ":FzfLua files" or ":Telescope find_files",
					},
					{ icon = icons.ui.NewFile, key = "e", desc = "New file", action = ":ene" },
					{
						icon = icons.git.Repo,
						key = "p",
						desc = "Find project",
						action = ":Telescope projects",
					},
					{
						icon = icons.ui.Sort,
						key = "y",
						desc = "File frecency",
						action = ":Telescope frecency",
					},
					{
						icon = icons.ui.History,
						key = "r",
						desc = "Recent files",
						action = use_fzf and ":FzfLua oldfiles" or ":Telescope oldfiles",
					},
					{
						icon = icons.ui.List,
						key = "t",
						desc = "Find text",
						action = use_fzf and ":FzfLua live_grep" or ":Telescope live_grep",
					},
					{
						icon = icons.ui.CloudDownload,
						key = "u",
						desc = "Update",
						action = ":Lazy sync",
					},
					{ icon = icons.ui.SignOut, key = "q", desc = "Quit", action = ":qa" },
				},
			},
			sections = {
				{ section = "header", hl = "SnacksDashboardHeader" },
				{ section = "keys", gap = 1, padding = 1 },
				{ section = "startup" },
			},
		},
		indent = {
			enabled = true,
			indent = {
				char = "│",
				only_scope = false,
			},
			animate = {
				enabled = true,
				style = "out",
				easing = "linear",
				duration = { step = 20, total = 300 },
			},
			scope = {
				enabled = true,
				char = "┃",
				underline = false,
			},
			chunk = { enabled = false },
			---@param buf number
			---@param win number
			filter = function(buf, win)
				local excluded_ft = {
					[""] = true,
					checkhealth = true,
					["dap-repl"] = true,
					diff = true,
					fugitive = true,
					fugitiveblame = true,
					git = true,
					gitcommit = true,
					help = true,
					log = true,
					markdown = true,
					Outline = true,
					qf = true,
					snacks_dashboard = true,
					TelescopePrompt = true,
					text = true,
					undotree = true,
					vimwiki = true,
				}
				return vim.g.snacks_indent ~= false
					and vim.b[buf].snacks_indent ~= false
					and vim.bo[buf].buftype == ""
					and not excluded_ft[vim.bo[buf].filetype]
			end,
		},
		lazygit = { enabled = true },
		notifier = {
			enabled = true,
			timeout = 2000,
			icons = {
				error = icons.diagnostics.Error,
				warn = icons.diagnostics.Warning,
				info = icons.diagnostics.Information,
				debug = icons.ui.Bug,
				trace = icons.ui.Pencil,
			},
			style = "compact",
		},
		scroll = {
			enabled = true,
			animate = {
				duration = { step = 15, total = 150 },
			},
		},
		terminal = { enabled = true },
		quickfile = { enabled = true },
		-- Disable unused modules
		animate = { enabled = false },
		dim = { enabled = false },
		explorer = { enabled = false },
		input = { enabled = false },
		picker = { enabled = false },
		scope = { enabled = false },
		statuscolumn = { enabled = false },
		toggle = { enabled = false },
		words = { enabled = false },
		zen = { enabled = false },
	})
end
