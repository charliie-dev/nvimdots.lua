local editor = {}

editor["rainbowhxch/accelerated-jk.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("editor.accelerated-jk"),
}
editor["max397574/better-escape.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = require("editor.better-escape"),
}
editor["LunarVim/bigfile.nvim"] = {
	lazy = false,
	config = require("editor.bigfile"),
	cond = require("core.settings").load_big_files_faster,
}
editor["ojroques/nvim-bufdel"] = {
	lazy = true,
	event = "BufReadPost",
}
editor["s1n7ax/nvim-comment-frame"] = {
	lazy = true,
	event = { "BufNewFile", "BufReadPre" },
	config = require("editor.comment-frame"),
	dependencies = "nvim-treesitter/nvim-treesitter",
}
editor["numToStr/Comment.nvim"] = {
	lazy = true,
	event = { "BufNewFile", "BufReadPre" },
	config = require("editor.comment"),
	dependencies = "nvim-treesitter/nvim-treesitter",
}
editor["sindrets/diffview.nvim"] = {
	lazy = true,
	cmd = {
		"DiffviewOpen",
		"DiffviewFileHistory",
		"DiffviewFocusFiles",
		"DiffviewToggleFiles",
		"DiffviewRefresh",
	},
}
editor["junegunn/vim-easy-align"] = {
	lazy = true,
	cmd = "EasyAlign",
}
editor["RRethy/vim-illuminate"] = {
	lazy = true,
	event = "BufReadPost",
	config = require("editor.illuminate"),
}
editor["ggandor/leap.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("leap").opts.highlight_unlabeled_phase_one_targets = true
		require("leap").add_default_mappings()
	end,
}
editor["danymat/neogen"] = {
	lazy = true,
	cmd = "Neogen",
	config = require("editor.neogen"),
	dependencies = "nvim-treesitter/nvim-treesitter",
}
editor["roobert/search-replace.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = require("editor.search-replace"),
}
editor["kylechui/nvim-surround"] = {
	lazy = true,
	event = "BufReadPre",
	config = require("editor.surround"),
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
}
editor["romainl/vim-cool"] = {
	lazy = true,
	event = { "CursorMoved", "InsertEnter" },
}

----------------------------------------------------------------------
--                  :treesitter related plugins                    --
----------------------------------------------------------------------
editor["nvim-treesitter/nvim-treesitter"] = {
	lazy = true,
	run = ":TSUpdate",
	event = "BufReadPost",
	config = require("editor.treesitter"),
	dependencies = {
		{ "andymass/vim-matchup" },
		{ "p00f/nvim-ts-rainbow" },
		{ "mfussenegger/nvim-ts-hint-textobject" },
		{ "JoosepAlviste/nvim-ts-context-commentstring" },
		{ "nvim-treesitter/nvim-treesitter-textobjects" },
		{
			"chrisgrieser/nvim-various-textobjs",
			config = function()
				require("various-textobjs").setup({
					lookForwardLines = 15, -- default: 5. Set to 0 to only look in the current line
					useDefaultKeymaps = false,
				})
			end,
		},
		{
			"windwp/nvim-ts-autotag",
			config = require("editor.autotag"),
		},
		{
			"m-demare/hlargs.nvim",
			config = require("editor.hlargs"),
		},
		{
			"Wansmer/treesj",
			config = require("editor.treesj"),
		},
		{
			"folke/paint.nvim",
			config = require("editor.paint"),
		},
		{
			"ziontee113/syntax-tree-surfer",
			config = require("editor.tree-surfer"),
		},
		{
			"NvChad/nvim-colorizer.lua",
			config = require("editor.colorizer"),
		},
		{
			"abecodes/tabout.nvim",
			config = require("editor.tabout"),
		},
	},
}
editor["nvim-treesitter/playground"] = {
	lazy = true,
	cmd = {
		"TSHighlightCapturesUnderCursor",
		"TSPlaygroundToggle",
	},
}

return editor
