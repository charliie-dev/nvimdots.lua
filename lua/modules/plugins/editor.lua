local editor = {}

-- editor["m4xshen/autoclose.nvim"] = {
-- 	lazy = true,
-- 	event = "InsertEnter",
-- 	config = require("editor.autoclose"),
-- }
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
	config = require("editor.diffview"),
}
editor["echasnovski/mini.align"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("editor.align"),
}
editor["echasnovski/mini.surround"] = {
	lazy = true,
	event = { "BufNewFile", "BufReadPre" },
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
	init = require("editor.suda"),
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
editor["tzachar/local-highlight.nvim"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = require("editor.local-highlight"),
}
editor["brenoprata10/nvim-highlight-colors"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("editor.highlight-colors"),
}
editor["tpope/vim-sleuth"] = {
	lazy = true,
	event = { "BufNewFile", "BufReadPost", "BufFilePost" },
}
editor["nvim-pack/nvim-spectre"] = {
	lazy = true,
	cmd = "Spectre",
}
editor["mrjones2014/smart-splits.nvim"] = {
	lazy = true,
	event = { "CursorHoldI", "CursorHold" },
	config = require("editor.splits"),
}
editor["joshuadanpeterson/typewriter.nvim"] = {
	lazy = true,
	event = "BufReadPre",
	dependencies = "nvim-treesitter/nvim-treesitter",
	config = require("editor.typewriter"),
	init = function()
		require("typewriter.commands").enable_typewriter_mode()
	end,
}

----------------------------------------------------------------------
--                  :treesitter related plugins                    --
----------------------------------------------------------------------
editor["nvim-treesitter/nvim-treesitter"] = {
	lazy = true,
	build = function()
		if vim.fn.has("gui_running") == 1 then
			vim.api.nvim_command([[TSUpdate]])
		end
	end,
	event = "BufReadPre",
	config = require("editor.treesitter"),
	dependencies = {
		{ "andymass/vim-matchup" },
		{ "nvim-treesitter/nvim-treesitter-textobjects" },
		{
			"windwp/nvim-ts-autotag",
			config = require("editor.autotag"),
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
