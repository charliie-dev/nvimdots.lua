local editor = {}

-- editor["m4xshen/autoclose.nvim"] = {
-- 	lazy = true,
-- 	event = "InsertEnter",
-- 	config = require("editor.autoclose"),
-- }
editor["pteroctopus/faster.nvim"] = {
	lazy = false,
	cond = require("core.settings").load_big_files_faster,
	config = require("editor.faster"),
}
editor["ojroques/nvim-bufdel"] = {
	lazy = true,
	cmd = { "BufDel", "BufDelAll", "BufDelOthers" },
}
-- editor["s1n7ax/nvim-comment-frame"] = {
-- 	lazy = true,
-- 	event = { "CursorHold", "CursorHoldI" },
-- 	config = require("editor.comment-frame"),
-- 	dependencies = "nvim-treesitter/nvim-treesitter",
-- }
editor["numToStr/Comment.nvim"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("editor.comment"),
	dependencies = "nvim-treesitter/nvim-treesitter",
}
editor["sindrets/diffview.nvim"] = {
	lazy = true,
	cmd = { "DiffviewOpen", "DiffviewClose" },
	config = require("editor.diffview"),
}
editor["echasnovski/mini.align"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("editor.align"),
}
editor["echasnovski/mini.cursorword"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = require("editor.cursorword"),
}
editor["echasnovski/mini.surround"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	version = false,
	config = require("editor.surround"),
}
-- NOTE: `flash.nvim` is a powerful plugin that can be used as partial or complete replacements for:
--  > `hop.nvim`,
--  > `wilder.nvim`
--  > `nvim-treehopper`
-- Considering its steep learning curve as well as backward compatibility issues...
--  > We have no plan to remove the above plugins for the time being.
-- But as usual, you can always tweak the plugin to your liking.
editor["folke/flash.nvim"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("editor.flash"),
}
editor["danymat/neogen"] = {
	lazy = true,
	cmd = "Neogen",
	config = require("editor.neogen"),
	dependencies = "nvim-treesitter/nvim-treesitter",
}
editor["olimorris/persisted.nvim"] = {
	lazy = true,
	cmd = {
		"SessionToggle",
		"SessionStart",
		"SessionStop",
		"SessionSave",
		"SessionLoad",
		"SessionLoadLast",
		"SessionLoadFromFile",
		"SessionDelete",
	},
	config = require("editor.persisted"),
}
editor["lambdalisue/suda.vim"] = {
	lazy = true,
	cmd = { "SudaRead", "SudaWrite" },
	init = require("editor.suda"),
}
editor["romainl/vim-cool"] = {
	lazy = true,
	event = { "CursorMoved", "InsertEnter" },
}
editor["brenoprata10/nvim-highlight-colors"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("editor.highlight-colors"),
}
editor["MagicDuck/grug-far.nvim"] = {
	lazy = true,
	cmd = "GrugFar",
	config = require("editor.grug-far"),
}
-- editor["joshuadanpeterson/typewriter.nvim"] = {
-- 	lazy = true,
-- 	event = "BufReadPre",
-- 	dependencies = "nvim-treesitter/nvim-treesitter",
-- 	config = require("editor.typewriter"),
-- 	init = function()
-- 		require("typewriter.commands").enable_typewriter_mode()
-- 	end,
-- }

----------------------------------------------------------------------
--                  :treesitter related plugins                    --
----------------------------------------------------------------------
editor["nvim-treesitter/nvim-treesitter"] = {
	lazy = true,
	build = function()
		if #vim.api.nvim_list_uis() > 0 then
			vim.api.nvim_command([[TSUpdate]])
		end
	end,
	event = "BufReadPre",
	config = require("editor.treesitter"),
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter-textobjects" },
		{
			"andymass/vim-matchup",
			init = require("editor.matchup"),
		},
		{
			"windwp/nvim-ts-autotag",
			config = require("editor.ts-autotag"),
		},
		{
			"hiphish/rainbow-delimiters.nvim",
			config = require("editor.rainbow_delims"),
		},
		{
			"nvim-treesitter/nvim-treesitter-context",
			config = require("editor.ts-context"),
		},
		{
			"JoosepAlviste/nvim-ts-context-commentstring",
			config = require("editor.ts-context-commentstring"),
		},
		{
			"echasnovski/mini.ai",
			version = "*",
			config = require("editor.ai_textobj"),
		},
	},
}

return editor
