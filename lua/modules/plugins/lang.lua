local lang = {}

lang["lukas-reineke/headlines.nvim"] = {
	lazy = true,
	ft = { "markdown", "org" },
	config = require("lang.headlines"),
}
lang["iamcco/markdown-preview.nvim"] = {
	lazy = true,
	ft = "markdown",
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
lang["AckslD/swenv.nvim"] = {
	lazy = true,
	ft = "python",
	config = require("lang.swenv"),
}
lang["mtdl9/vim-log-highlighting"] = {
	lazy = true,
	ft = {
		"text",
		"txt",
		"log",
	},
}
lang["chr4/nginx.vim"] = {
	lazy = true,
	ft = "conf",
}

return lang
