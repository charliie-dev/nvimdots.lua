local is_windows = require("core.global").is_windows
local lang = {}

lang["kevinhwang91/nvim-bqf"] = {
	lazy = true,
	ft = "qf",
	config = require("lang.bqf"),
	dependencies = {
		{ "junegunn/fzf", build = ":call fzf#install()" },
	},
}
lang["stevearc/quicker.nvim"] = {
	lazy = true,
	ft = "qf",
	opts = {},
}
lang["ray-x/go.nvim"] = {
	lazy = true,
	ft = { "go", "gomod", "gosum" },
	config = require("lang.go"),
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
