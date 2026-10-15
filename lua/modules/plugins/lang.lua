local is_windows = require("core.global").is_windows
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
	dependencies = {
		{
			"ray-x/guihua.lua",
			build = not is_windows and "cd lua/fzy && make",
		},
	},
}
lang["bullets-vim/bullets.vim"] = {
	lazy = true,
	ft = { "markdown", "text", "gitcommit" },
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
