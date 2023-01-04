vim.api.nvim_command([[packadd nvim-treesitter]])

-- Structural search and replace
require("ssr").setup({
	min_width = 50,
	min_height = 5,
	keymaps = {
		close = "q",
		next_match = "n",
		prev_match = "p",
		replace_all = "<leader><cr>",
	},
})
