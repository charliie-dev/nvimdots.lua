local lang = {}

lang["preservim/vim-markdown"] = {
	opt = true,
	ft = "markdown",
	config = function()
		require("modules.lang.markdown")
	end,
}
lang["iamcco/markdown-preview.nvim"] = {
	opt = true,
	ft = "markdown",
	run = function()
		vim.fn["mkdp#util#install"]()
	end,
	config = function()
		require("modules.lang.mkdp")
	end,
}
lang["lervag/vimtex"] = {
	opt = true,
	ft = "tex",
	config = function()
		require("modules.lang.vimtex")
	end,
}
-- lang["jbyuki/nabla.nvim"] = { --TODO:
-- 	opt = true,
-- 	ft = "tex",
-- 	requires = "nvim-treesitter/nvim-treesitter",
-- }
lang["ranelpadon/python-copy-reference.vim"] = {
	opt = true,
	ft = "python",
	cmd = { "PythonCopyReferenceDotted", "PythonCopyReferencePytest" },
}
lang["AckslD/swenv.nvim"] = {
	opt = true,
	ft = "python",
	config = function()
		require("modules.lang.swenv")
	end,
}
lang["mtdl9/vim-log-highlighting"] = {
	opt = true,
	ft = {
		"text",
		"txt",
		"log",
	},
}

return lang
