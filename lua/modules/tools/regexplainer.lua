require("regexplainer").setup({
	-- 'narrative'
	mode = "narrative", -- TODO: 'ascii', 'graphical'

	-- automatically show the explainer when the cursor enters a regexp
	auto = true,

	-- filetypes (i.e. extensions) in which to run the autocommand
	filetypes = {
		"html",
		"js",
		"cjs",
		"mjs",
		"ts",
		"jsx",
		"tsx",
		"cjsx",
		"mjsx",
		"go",
		"lua",
		"vim",
	},

	mappings = {
		toggle = "<Leader>gR",
		-- examples, not defaults:
		-- show = 'gS',
		-- hide = 'gH',
		-- show_split = 'gP',
		-- show_popup = 'gU',
	},

	narrative = {
		separator = function(component)
			local sep = "\n"
			if component.depth > 0 then
				for _ = 1, component.depth do
					sep = sep .. "> "
				end
			end
			return sep
		end,
	},
})
