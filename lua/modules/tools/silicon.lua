require("silicon").setup({

	-- The following key is required if you want to save image to file instead of clipboard
	output = "./silicon.png",
	-- The following keys are all optional
	-- with default values
	font = "Hack=20",
	theme = "Monokai Extended",
	background = "#ABB8C3",
	shadow = {
		blur_radius = 0.0,
		offset_x = 0,
		offset_y = 0,
		color = "#555",
	},
	pad_horiz = 100,
	pad_vert = 80,
	line_number = false,
	line_pad = 1,
	line_offset = 1,
	tab_width = 4,
	round_corner = true,
	window_controls = true,
})

-- NOTE: If you have issue copying images to the clipboard, for example you're in a wsl.
-- NOTE: Please assign /path/to/file.png after :Silicon.
