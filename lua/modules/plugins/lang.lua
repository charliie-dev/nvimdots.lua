local lang = {}

lang["kevinhwang91/nvim-bqf"] = {
	lazy = true,
	ft = "qf",
	config = require("lang.bqf"),
	dependencies = {
		{ "junegunn/fzf", build = ":call fzf#install()" },
		{ "stevearc/quicker.nvim", opts = {} },
	},
}
lang["ray-x/go.nvim"] = {
	lazy = true,
	ft = { "go", "gomod", "gosum" },
	config = require("lang.go"),
	dependencies = "ray-x/guihua.lua",
}
lang["bullets-vim/bullets.vim"] = {
	lazy = true,
	ft = { "markdown", "text", "gitcommit" },
}
lang["OXY2DEV/markview.nvim"] = {
	lazy = false,
	config = require("lang.markview"),
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"nvim-treesitter/nvim-treesitter",
	},
}
lang["iamcco/markdown-preview.nvim"] = {
	lazy = true,
	ft = { "markdown" },
	build = ":call mkdp#util#install()",
	init = require("lang.markdown-preview"),
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
