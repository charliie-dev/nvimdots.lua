local lang = {}

lang["kevinhwang91/nvim-bqf"] = {
	lazy = true,
	ft = "qf",
	config = require("modules.configs.lang.bqf"),
	-- fzf's Vim API runs the fzf on PATH (installed by home-manager); no downloaded binary
	dependencies = { "junegunn/fzf" },
}
lang["stevearc/quicker.nvim"] = {
	lazy = true,
	ft = "qf",
	opts = {},
}
lang["ray-x/go.nvim"] = {
	lazy = true,
	-- gowork: :GoWork, :GoModTidy and :GoGet also apply when go.work is the first file
	ft = { "go", "gomod", "gosum", "gowork" },
	config = require("modules.configs.lang.go"),
	-- guihua's fzy matcher falls back to pure Lua without the native library, so nothing is compiled
	dependencies = { "ray-x/guihua.lua" },
}
lang["bullets-vim/bullets.nvim"] = {
	lazy = true,
	ft = { "markdown", "text", "gitcommit" },
	opts = {
		-- bullets.vim also demoted and promoted a Visual selection with > and <. bullets.nvim then
		-- renumbers only the selected lines (bullets-vim/bullets.nvim#31), so renumber the whole list
		-- afterwards as bullets.vim did.
		custom_mappings = {
			{ "x", ">", "<Esc><Cmd>'<,'>BulletDemoteVisual<CR><Cmd>RenumberList<CR>" },
			{ "x", "<", "<Esc><Cmd>'<,'>BulletPromoteVisual<CR><Cmd>RenumberList<CR>" },
		},
	},
}
lang["ranelpadon/python-copy-reference.vim"] = {
	lazy = true,
	ft = "python",
}
lang["fei6409/log-highlight.nvim"] = {
	lazy = true,
	ft = "log",
	opts = {},
}

return lang
