require("zen-mode").setup({
	window = {
		backdrop = 0.7, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normalized
		options = {
			signcolumn = "no", -- disable signcolumn
			number = true, -- disable number column
			relativenumber = true, -- disable relative numbers
			cursorline = false, -- disable cursorline
			cursorcolumn = false, -- disable cursor column
			foldcolumn = "0", -- disable fold column
			list = false, -- disable whitespace characters
		},
	},
	plugins = {
		options = {
			enabled = true,
			ruler = false,
			showcmd = false,
		},
		gitsigns = { enabled = false }, -- disables git signs
		tmux = { enabled = false }, -- disables the tmux statusline
	},
})
