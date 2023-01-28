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
-- lang["preservim/vim-markdown"] = {
-- 	lazy = true,
-- 	ft = "markdown",
-- 	config = function()
-- 		require("modules.lang.markdown")
-- 	end,
-- }
lang["antonk52/markdowny.nvim"] = {
	lazy = true,
	ft = { "markdown", "txt" },
	config = function()
		require("modules.lang.markdowny")
	end,
}
lang["jakewvincent/mkdnflow.nvim"] = {
	lazy = true,
	ft = "markdown",
	-- rocks = "luautf9", --move to scripts/setup_config.sh to shorten PackerSync time
	config = function()
		vim.lazy_local.conceallevel = 3 -- Links and text formatting
		vim.lazy_local.concealcursor = "n" -- Reveal the conceal item in current line
		require("modules.lang.mkdnflow")
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
lang["jbyuki/nabla.nvim"] = {
	lazy = true,
	ft = "tex",
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
