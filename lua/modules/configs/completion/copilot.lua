return function()
	vim.defer_fn(function()
		require("modules.utils").load_plugin("copilot", {
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
				gitrebase = false,
				hgcommit = false,
				svn = false,
				cvs = false,
				["."] = false,
				["bigfile"] = false,
				["dap-repl"] = false,
				["fugitive"] = false,
				["fugitiveblame"] = false,
				["git"] = false,
				["gitcommit"] = false,
				["log"] = false,
				["toggleterm"] = false,
			},
		})
	end, 100)
end
