require("nvim-comment-frame").setup({
	-- width of the comment frame
	frame_width = 70,

	-- wrap the line after 'n' characters
	line_wrap_len = 50,

	-- automatically indent the comment frame based on the line
	auto_indent = true,

	-- add comment above the current line
	add_comment_above = true,

	languages = {
		-- configuration for Lua programming language
		-- @NOTE global configuration will be overridden by language level
		-- configuration if provided
		lua = {
			start_str = "--",
			end_str = "--",
			fill_char = "-",
		},
		bash = {
			start_str = "#",
			end_str = "#",
			fill_char = "#",
		},
		python = {
			start_str = "#",
			end_str = "#",
			fill_char = "#",
		},
	},
})
