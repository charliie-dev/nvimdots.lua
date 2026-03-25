vim.filetype.add({
	filename = {
		[".env"] = "dotenv",
	},
	pattern = {
		[".*"] = {
			function(path)
				if vim.fn.fnamemodify(path, ":t"):match("^%.env%.") then
					return "dotenv"
				end
			end,
			{ priority = 10 },
		},
	},
})
