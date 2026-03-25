vim.filetype.add({
	filename = {
		[".env"] = "dotenv",
	},
	pattern = {
		[".*"] = {
			function(path)
				local tail = path:match("[/\\]([^/\\]+)$") or path
				if tail:match("^%.env%.") then
					return "dotenv"
				end
			end,
			{ priority = 10 },
		},
	},
})
