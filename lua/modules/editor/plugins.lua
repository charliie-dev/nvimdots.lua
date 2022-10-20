local editor = {}

editor["rainbowhxch/accelerated-jk.nvim"] = {
	opt = true,
	event = "InsertEnter",
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
	after = "nvim-treesitter",
	branch = "bug/10",
	config = function()
		require("modules.editor.comment-frame")
	end,
}
editor["numToStr/Comment.nvim"] = {
	opt = true,
	event = "BufReadPost",
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
editor["booperlv/nvim-gomove"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.editor.gomove")
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
		require("modules.editor.leap")
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
-- editor["nvim-pack/nvim-spectre"] = {
-- 	opt = true,
-- 	event = "BufReadPost",
-- 	requires = {
-- 		{ "nvim-lua/plenary.nvim", opt = false },
-- 	},
-- 	config = function()
-- 		require("modules.editor.spectre")
-- 	end,
-- }
-- editor["kylechui/nvim-surround"] = {
-- 	opt = true,
-- 	event = "BufReadPre",
-- 	after = {
-- 		"nvim-treesitter",
-- 		"nvim-treesitter-textobjects",
-- 	},
-- 	config = function()
-- 		require("modules.editor.surround")
-- 	end,
-- }
-- editor["abecodes/tabout.nvim"] = {
-- 	opt = true,
-- 	event = "InsertEnter",
-- 	wants = "nvim-treesitter",
-- 	after = "nvim-cmp",
-- 	config = function()
-- 		require("modules.editor.tabout")
-- 	end,
-- }
editor["andymass/vim-matchup"] = {
	opt = true,
	cmd = { "MatchupWhereAmI" },
	after = "nvim-treesitter",
}
editor["romainl/vim-cool"] = {
	opt = true,
	event = { "CursorMoved", "InsertEnter" },
}
editor["famiu/bufdelete.nvim"] = {
	opt = true,
	cmd = { "Bdelete", "Bwipeout", "Bdelete!", "Bwipeout!" },
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
editor["olambo/vi-viz"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.editor.viz")
	end,
}

----------------------------------------------------------------------
--                  :treesitter related plugins                    --
----------------------------------------------------------------------
editor["nvim-treesitter/nvim-treesitter"] = {
	opt = true,
	run = ":TSUpdate",
	event = "BufReadPost",
	module = {
		"nvim-treesitter",
		"nvim-treesitter.parsers",
	},
	config = function()
		require("modules.editor.treesitter")
	end,
}
editor["nvim-treesitter/playground"] = {
	opt = true,
	cmd = "TSPlaygroundToggle",
}
editor["nvim-treesitter/nvim-treesitter-textobjects"] = {
	opt = true,
	after = "nvim-treesitter",
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
-- editor["David-Kunz/markid"] = {
-- 	opt = true,
-- 	after = "nvim-treesitter",
-- }
editor["AckslD/nvim-trevJ.lua"] = {
	opt = true,
	after = "nvim-treesitter",
	module = "trevj",
	config = function()
		require("modules.editor.trevj")
	end,
}

return editor
