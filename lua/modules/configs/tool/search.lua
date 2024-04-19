return function()
	local builtin = require("telescope.builtin")
	require("search").setup({
		append_tabs = { -- append_tabs will add the provided tabs to the default ones
			{
				"Commits", -- or name = "Commits"
				builtin.git_commits, -- or tele_func = require('telescope.builtin').git_commits
				available = function() -- optional
					return vim.fn.isdirectory(".git") == 1
				end,
			},
		},
		-- -- its also possible to overwrite the default tabs using the tabs key instead of append_tabs
		-- tabs = {
		-- 	{
		-- 		"Files",
		-- 		function(opts)
		-- 			opts = opts or {}
		-- 			if vim.fn.isdirectory(".git") == 1 then
		-- 				builtin.git_files(opts)
		-- 			else
		-- 				builtin.find_files(opts)
		-- 			end
		-- 		end,
		-- 	},
		-- },
	})
end
