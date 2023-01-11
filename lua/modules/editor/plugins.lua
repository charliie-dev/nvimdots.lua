local editor = {}

editor["rainbowhxch/accelerated-jk.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.editor.accelerated-jk")
	end,
}
editor["max397574/better-escape.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.editor.better-escape")
	end,
}
editor["s1n7ax/nvim-comment-frame"] = {
	opt = true,
	event = "BufReadPost",
	requires = "nvim-treesitter/nvim-treesitter",
	branch = "bug/10",
	config = function()
		require("modules.editor.comment-frame")
	end,
}
editor["numToStr/Comment.nvim"] = {
	opt = true,
	event = "BufReadPost",
	requires = "nvim-treesitter/nvim-treesitter",
	config = function()
		require("modules.editor.comment")
	end,
}
editor["junegunn/vim-easy-align"] = {
	opt = true,
	cmd = "EasyAlign",
}
editor["akinsho/git-conflict.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.editor.git-conflict")
	end,
}
editor["dinhhuy258/git.nvim"] = {
	opt = true,
	cmd = { "Git", "GitBlame", "GitDiff", "GitDiffClose", "GitRevert", "GitRevertFile" },
	config = function()
		require("modules.editor.git-nvim")
	end,
}
editor["RRethy/vim-illuminate"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.editor.illuminate")
	end,
}
editor["ggandor/leap.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("leap").opts.highlight_unlabeled_phase_one_targets = true
		require("leap").add_default_mappings()
	end,
}
editor["ggandor/flit.nvim"] = {
	opt = true,
	after = "leap.nvim",
	requires = "ggandor/leap.nvim",
	config = function()
		require("modules.editor.flit")
	end,
}
editor["danymat/neogen"] = {
	opt = true,
	cmd = { "Neogen" },
	module = "neogen",
	requires = "nvim-treesitter/nvim-treesitter",
	config = function()
		require("modules.editor.neogen")
	end,
}
editor["nacro90/numb.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.editor.numb")
	end,
}
-- editor["ThePrimeagen/refactoring.nvim"] = {
-- 	opt = true,
-- 	requires = {
-- 		{ "nvim-lua/plenary.nvim" },
-- 		{ "nvim-treesitter/nvim-treesitter" },
-- 	},
-- 	config = function()
-- 		require("modules.editor.refactoring")
-- 	end,
-- }
-- editor["edluffy/specs.nvim"] = {
-- 	opt = true,
-- 	event = "CursorMoved",
-- 	config = function()
-- 		require("modules.editor.specs")
-- 	end,
-- }
-- editor["cshuaimin/ssr.nvim"] = {
-- 	opt = true,
-- 	event = "BufReadPost",
-- 	module = "ssr",
-- 	requires = "nvim-treesitter/nvim-treesitter",
-- 	config = function()
-- 		require("modules.editor._ssr")
-- 	end,
-- }
editor["roobert/search-replace.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.editor._search-replace")
	end,
}
editor["kylechui/nvim-surround"] = {
	opt = true,
	event = "BufReadPre",
	after = {
		"nvim-treesitter",
		"nvim-treesitter-textobjects",
	},
	config = function()
		require("modules.editor.surround")
	end,
}
editor["andymass/vim-matchup"] = {
	opt = true,
	cmd = { "MatchupWhereAmI" },
	after = "nvim-treesitter",
}
editor["ojroques/nvim-bufdel"] = {
	opt = true,
	event = "BufReadPost",
}
editor["sindrets/diffview.nvim"] = {
	opt = true,
	cmd = {
		"DiffviewOpen",
		"DiffviewFileHistory",
		"DiffviewFocusFiles",
		"DiffviewToggleFiles",
		"DiffviewRefresh",
	},
}
editor["simrat39/symbols-outline.nvim"] = {
	opt = true,
	cmd = { "SymbolsOutline" },
	config = function()
		require("modules.editor.symbols-outline")
	end,
}
editor["Pocco81/true-zen.nvim"] = {
	opt = true,
	cmd = {
		"TZAtaraxis", -- Strong remove all visual hints and center current buffer
		"TZMinimalist", -- Soft remove all visual hints
		"TZNarrow", -- Narrow to region
		"TZFocus", -- Focus on current window
	},
	config = function()
		require("modules.editor.true-zen")
	end,
}

----------------------------------------------------------------------
--                  :treesitter related plugins                    --
----------------------------------------------------------------------
editor["nvim-treesitter/nvim-treesitter"] = {
	opt = true,
	run = ":TSUpdate",
	event = "BufReadPost",
	config = function()
		require("modules.editor.treesitter")
	end,
}
editor["nvim-treesitter/playground"] = {
	opt = true,
	cmd = {
		"TSHighlightCapturesUnderCursor",
		"TSPlaygroundToggle",
	},
}
editor["nvim-treesitter/nvim-treesitter-textobjects"] = {
	opt = true,
	after = "nvim-treesitter",
}
editor["chrisgrieser/nvim-various-textobjs"] = {
	opt = true,
	after = "nvim-treesitter",
	config = function()
		require("various-textobjs").setup({
			lookForwardLines = 15, -- default: 5. Set to 0 to only look in the current line
			useDefaultKeymaps = false,
		})
	end,
}
editor["p00f/nvim-ts-rainbow"] = {
	opt = true,
	after = "nvim-treesitter",
}
editor["JoosepAlviste/nvim-ts-context-commentstring"] = {
	opt = true,
	after = "nvim-treesitter",
	module = "ts_context_commentstring.integrations.comment_nvim",
}
editor["mfussenegger/nvim-ts-hint-textobject"] = {
	opt = true,
	after = "nvim-treesitter",
}
editor["windwp/nvim-ts-autotag"] = {
	opt = true,
	after = "nvim-treesitter",
	config = function()
		require("modules.editor.ts-autotag")
	end,
}
editor["m-demare/hlargs.nvim"] = {
	opt = true,
	after = "nvim-treesitter",
	config = function()
		require("modules.editor.ts-hlargs")
	end,
}
editor["Wansmer/treesj"] = {
	opt = true,
	after = "nvim-treesitter",
	module = "treesj",
	cmd = {
		"TSJToggle",
		"TSJSplit",
		"TSJJoin",
	},
	config = function()
		require("modules.editor.treesj")
	end,
}
editor["folke/paint.nvim"] = { -- replacement for tree-sitter-comment parser
	opt = true,
	after = "nvim-treesitter",
	config = function()
		require("modules.editor.paint")
	end,
}
editor["ziontee113/syntax-tree-surfer"] = {
	opt = true,
	after = "nvim-treesitter",
	config = function()
		require("modules.editor.tree-surfer")
	end,
}

return editor
