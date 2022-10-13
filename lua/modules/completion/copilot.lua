require("copilot").setup({
	cmp = {
		enabled = true,
		method = "getCompletionsCycling",
	},
	panel = {
		enabled = true,
		auto_refresh = false,
		keymap = {
			jump_prev = "[[",
			jump_next = "]]",
			accept = "<CR>",
			refresh = "gr",
			open = "<M-CR>",
		},
	},
	suggestion = {
		enabled = true,
		auto_trigger = false,
		debounce = 75,
		keymap = {
			accept = "<M-l>",
			next = "<M-]>",
			prev = "<M-[>",
			dismiss = "<C-]>",
		},
	},
	filetypes = {
		yaml = false,
		markdown = false,
		help = false,
		terraform = false,
		gitcommit = false,
		gitrebase = false,
		hgcommit = false,
		svn = false,
		cvs = false,
		["."] = false,
	},
	plugin_manager_path = vim.fn.stdpath("data") .. "/site/pack/packer",
	-- plugin_manager_path = vim.env.HOME .. "/.config/nvim/plugged"
	-- Use this field to provide the path to a specific node version such as one installed by nvm. Node version must be < 18.
	-- copilot_node_command = vim.fn.expand("$HOME") .. "/tools/nodejs/bin/node", -- Node version must be < 18
	server_opts_overrides = {},
})
