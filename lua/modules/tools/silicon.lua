local cmd = vim.api.nvim_command

require("silicon").setup({
	theme = vim.g.colors_name,
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
	lineNumber = true,
	font = "monospace",
	lineOffset = 1, -- from where to start line number
	linePad = 2, -- padding between lines
	padHoriz = 80, -- Horizontal padding
	padVert = 100, -- vertical padding
	shadowBlurRadius = 10,
	shadowColor = "#555555",
	shadowOffsetX = 8,
	shadowOffsetY = 8,
	gobble = false, -- enable lsautogobble like feature(remove indentation)
	debug = false, -- enable debug output
})

vim.api.nvim_create_augroup("SiliconRefresh", { clear = true })
vim.api.nvim_create_autocmd({ "ColorScheme" }, {
	group = "SiliconRefresh",
	callback = function()
		require("silicon.utils").build_tmTheme()
		require("silicon.utils").reload_silicon_cache({ async = true })
	end,
	desc = "Reload silicon themes cache on colorscheme switch",
})

cmd([[ command! Silicon execute 'lua require("silicon").visualise_cmdline({})' ]])

-- NOTE: u have to install silicon first.
-- NOTE: https://github.com/aloxaf/silicon
