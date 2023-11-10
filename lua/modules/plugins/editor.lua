local editor = {}

editor["rainbowhxch/accelerated-jk.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("editor.accelerated-jk"),
}
editor["m4xshen/autoclose.nvim"] = {
	lazy = true,
	event = "InsertEnter",
	config = require("editor.autoclose"),
}
editor["max397574/better-escape.nvim"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("editor.better-escape"),
}
editor["LunarVim/bigfile.nvim"] = {
	lazy = false,
	config = require("editor.bigfile"),
	cond = require("core.settings").load_big_files_faster,
}
editor["ojroques/nvim-bufdel"] = {
	lazy = true,
	cmd = { "BufDel", "BufDelAll", "BufDelOthers" },
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
	cmd = { "DiffviewOpen", "DiffviewClose" },
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
editor["junegunn/vim-easy-align"] = {
	lazy = true,
	cmd = "EasyAlign",
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
	config = require("editor.suda"),
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
editor["RRethy/vim-illuminate"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("editor.vim-illuminate"),
}

----------------------------------------------------------------------
--                  :treesitter related plugins                    --
----------------------------------------------------------------------
editor["nvim-treesitter/nvim-treesitter"] = {
	lazy = true,
	build = function()
		if #vim.api.nvim_list_uis() ~= 0 then
			vim.api.nvim_command("TSUpdate")
		end
	end,
	event = "BufReadPost",
	config = require("editor.treesitter"),
	dependencies = {
		{ "andymass/vim-matchup" },
		{ "JoosepAlviste/nvim-ts-context-commentstring" },
		{ "nvim-treesitter/nvim-treesitter-textobjects" },
		{
			"hiphish/rainbow-delimiters.nvim",
			config = require("editor.rainbow_delims"),
		},
		{
			"nvim-treesitter/nvim-treesitter-context",
			config = require("editor.ts-context"),
		},
		{
			"windwp/nvim-ts-autotag",
			config = require("editor.autotag"),
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
