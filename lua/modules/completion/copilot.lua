vim.defer_fn(function()
	require("copilot").setup({
		cmp = {
			enabled = true,
			method = "getCompletionsCycling",
		},
		panel = {
			-- if true, it can interfere with completions in copilot-cmp
			enabled = false,
		},
		suggestion = {
			-- if true, it can interfere with completions in copilot-cmp
			enabled = false,
		},
		filetypes = {
			yaml = false,
			toml = false,
			json = false,
			markdown = false,
			help = false,
			terraform = false,
			gitcommit = false,
			gitrebase = false,
			hgcommit = false,
			svn = false,
			cvs = false,
			["."] = false,
			["dap-repl"] = false,
			["big_file_disabled_ft"] = false,
		},
		plugin_manager_path = vim.fn.stdpath("data") .. "/site/pack/packer",
		-- Use this field to provide the path to a specific node version such as one installed by nvm. Node version must be < 18.
		-- copilot_node_command = vim.fn.expand("$HOME") .. "/tools/nodejs/bin/node", -- Node version must be < 18
		server_opts_overrides = {},
	})
end, 100)
