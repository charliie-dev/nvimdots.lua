local lang = {}

lang["gaoDean/autolist.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.lang.autolist")
	end,
}
lang["lukas-reineke/headlines.nvim"] = {
	opt = true,
	ft = { "markdown", "org" },
	config = function()
		require("modules.lang.headlines")
	end,
}
-- lang["preservim/vim-markdown"] = {
-- 	opt = true,
-- 	ft = "markdown",
-- 	config = function()
-- 		require("modules.lang.markdown")
-- 	end,
-- }
lang["antonk52/markdowny.nvim"] = {
	opt = true,
	ft = { "markdown", "txt" },
	config = function()
		require("modules.lang.markdowny")
	end,
}
lang["jakewvincent/mkdnflow.nvim"] = {
	opt = true,
	ft = "markdown",
	-- rocks = "luautf8", --move to scripts/setup_config.sh to shorten PackerSync time
	config = function()
		vim.opt_local.conceallevel = 2 -- Links and text formatting
		vim.opt_local.concealcursor = "n" -- Reveal the conceal item in current line
		require("modules.lang.mkdnflow")
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
lang["jbyuki/nabla.nvim"] = {
	opt = true,
	after = "nvim-treesitter",
	ft = "tex",
	requires = "nvim-treesitter/nvim-treesitter",
}
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
