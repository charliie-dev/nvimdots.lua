require("silicon").setup({
	theme = "Dracula",
	output = string.format(
		"./SILICON_%s-%s-%s_%s-%s.png",
		os.date("%Y"),
		os.date("%m"),
		os.date("%d"),
		os.date("%H"),
		os.date("%M")
	), -- auto generate file name based on time (absolute or relative to cwd)
	bgColor = vim.g.terminal_color_5,
	bgImage = "", -- path to image, must be png
	roundCorner = true,
	windowControls = true,
	lineNumber = false,
	font = "monospace",
	lineOffset = 1, -- from where to start line number
	linePad = 2, -- padding between lines
	padHoriz = 80, -- Horizontal padding
	padVert = 100, -- vertical padding
	shadowBlurRadius = 10,
	shadowColor = "#555555",
	shadowOffsetX = 0,
	shadowOffsetY = 0,
})

-- NOTE: u have to install silicon first.
-- NOTE: https://github.com/aloxaf/silicon
