local lang = {}

lang["gaoDean/autolist.nvim"] = {
	lazy = true,
	ft = { "markdown", "org", "txt" },
	config = function()
		require("modules.lang.autolist")
	end,
}
lang["lukas-reineke/headlines.nvim"] = {
	lazy = true,
	ft = { "markdown", "org" },
	config = function()
		require("modules.lang.headlines")
	end,
}
lang["antonk52/markdowny.nvim"] = {
	lazy = true,
	ft = { "markdown", "txt" },
	config = function()
		require("modules.lang.markdowny")
	end,
}
lang["iamcco/markdown-preview.nvim"] = {
	lazy = true,
	ft = "markdown",
	build = function()
		vim.fn["mkdp#util#install"]()
	end,
	config = function()
		require("modules.lang.mkdp")
	end,
}
lang["lervag/vimtex"] = {
	lazy = true,
	ft = "tex",
	config = function()
		require("modules.lang.vimtex")
	end,
}
lang["ranelpadon/python-copy-reference.vim"] = {
	lazy = true,
	ft = "python",
	cmd = { "PythonCopyReferenceDotted", "PythonCopyReferencePytest" },
}
lang["AckslD/swenv.nvim"] = {
	lazy = true,
	ft = "python",
	config = function()
		require("modules.lang.swenv")
	end,
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
