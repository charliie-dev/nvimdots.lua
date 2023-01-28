local editor = {}

editor["rainbowhxch/accelerated-jk.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.editor.accelerated-jk")
	end,
}
editor["max397574/better-escape.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.editor.better-escape")
	end,
}
editor["s1n7ax/nvim-comment-frame"] = {
	lazy = true,
	event = "BufReadPost",
	dependencies = "nvim-treesitter/nvim-treesitter",
	branch = "bug/10",
	config = function()
		require("modules.editor.comment-frame")
	end,
}
editor["numToStr/Comment.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	dependencies = "nvim-treesitter/nvim-treesitter",
	config = function()
		require("modules.editor.comment")
	end,
}
editor["junegunn/vim-easy-align"] = {
	lazy = true,
	cmd = "EasyAlign",
}
editor["akinsho/git-conflict.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.editor.git-conflict")
	end,
}
editor["dinhhuy258/git.nvim"] = {
	lazy = true,
	cmd = { "Git", "GitBlame", "GitDiff", "GitDiffClose", "GitRevert", "GitRevertFile" },
	config = function()
		require("modules.editor.git-nvim")
	end,
}
editor["RRethy/vim-illuminate"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.editor.illuminate")
	end,
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
	cmd = { "Neogen" },
	dependencies = "nvim-treesitter/nvim-treesitter",
	config = function()
		require("modules.editor.neogen")
	end,
}
editor["nacro90/numb.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.editor.numb")
	end,
}
-- editor["ThePrimeagen/refactoring.nvim"] = {
-- 	lazy = true,
-- 	requires = {
-- 		{ "nvim-lua/plenary.nvim" },
-- 		{ "nvim-treesitter/nvim-treesitter" },
-- 	},
-- 	config = function()
-- 		require("modules.editor.refactoring")
-- 	end,
-- }
-- editor["edluffy/specs.nvim"] = {
-- 	lazy = true,
-- 	event = "CursorMoved",
-- 	config = function()
-- 		require("modules.editor.specs")
-- 	end,
-- }
-- editor["cshuaimin/ssr.nvim"] = {
-- 	lazy = true,
-- 	event = "BufReadPost",
-- 	module = "ssr",
-- 	requires = "nvim-treesitter/nvim-treesitter",
-- 	config = function()
-- 		require("modules.editor.ssr")
-- 	end,
-- }
editor["roobert/search-replace.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.editor.search-replace")
	end,
}
editor["kylechui/nvim-surround"] = {
	lazy = true,
	event = "BufReadPre",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		require("modules.editor.surround")
	end,
}
editor["ojroques/nvim-bufdel"] = {
	lazy = true,
	event = "BufReadPost",
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

----------------------------------------------------------------------
--                  :treesitter related plugins                    --
----------------------------------------------------------------------
editor["nvim-treesitter/nvim-treesitter"] = {
	lazy = true,
	run = ":TSUpdate",
	event = "BufReadPost",
	config = function()
		require("modules.editor.treesitter")
	end,
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
			config = function()
				require("modules.editor.ts-autotag")
			end,
		},
		{
			"m-demare/hlargs.nvim",
			config = function()
				require("modules.editor.ts-hlargs")
			end,
		},
		{
			"Wansmer/treesj",
			config = function()
				require("modules.editor.treesj")
			end,
		},
		{
			"folke/paint.nvim",
			config = function()
				require("modules.editor.paint")
			end,
		},
		{
			"ziontee113/syntax-tree-surfer",
			config = function()
				require("modules.editor.tree-surfer")
			end,
		},
		{
			"NvChad/nvim-colorizer.lua",
			config = function()
				require("modules.editor.colorizer")
			end,
		},
		{
			"abecodes/tabout.nvim",
			config = function()
				require("modules.editor.tabout")
			end,
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
