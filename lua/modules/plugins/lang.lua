local lang = {}

lang["kevinhwang91/nvim-bqf"] = {
	lazy = true,
	ft = "qf",
	config = require("lang.bqf"),
	dependencies = {
		{ "junegunn/fzf", build = ":call fzf#install()" },
	},
}
lang["ray-x/go.nvim"] = {
	lazy = true,
	ft = { "go", "gomod", "gosum" },
	build = ":GoInstallBinaries",
	config = require("lang.go"),
	dependencies = "ray-x/guihua.lua",
}
lang["bullets-vim/bullets.vim"] = {
	lazy = true,
	ft = { "markdown", "text", "gitcommit" },
}
lang["MeanderingProgrammer/render-markdown.nvim"] = {
	lazy = true,
	ft = "markdown",
	config = require("lang.render-markdown"),
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"nvim-treesitter/nvim-treesitter",
	},
}
lang["iamcco/markdown-preview.nvim"] = {
	lazy = true,
	ft = { "markdown", "codecompanion" },
	build = ":call mkdp#util#install()",
	config = require("lang.markdown-preview"),
}
lang["lervag/vimtex"] = {
	lazy = true,
	ft = "tex",
	config = require("lang.vimtex"),
}
lang["ranelpadon/python-copy-reference.vim"] = {
	lazy = true,
	ft = "python",
	cmd = { "PythonCopyReferenceDotted", "PythonCopyReferencePytest" },
}
lang["mtdl9/vim-log-highlighting"] = {
	lazy = true,
	ft = {
		"text",
		"txt",
		"log",
	},
}

return lang
