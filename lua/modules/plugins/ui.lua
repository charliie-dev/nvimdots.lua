local ui = {}

ui["folke/snacks.nvim"] = {
	lazy = false,
	priority = 1000,
	config = require("ui.snacks"),
}
ui["akinsho/bufferline.nvim"] = {
	lazy = true,
	event = { "BufReadPre", "BufAdd", "BufNewFile" },
	config = require("ui.bufferline"),
}
ui["catppuccin/nvim"] = {
	lazy = false,
	name = "catppuccin",
	config = require("ui.catppuccin"),
}
ui["lewis6991/gitsigns.nvim"] = {
	lazy = true,
	event = { "BufReadPost", "BufNewFile" },
	config = require("ui.gitsigns"),
}
ui["nvim-lualine/lualine.nvim"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = require("ui.lualine"),
}
-- ui["sphamba/smear-cursor.nvim"] = {
-- 	lazy = true,
-- 	event = {
-- 		"CursorMoved", --[[CursorMovedC,]]
-- 		"CursorMovedI",
-- 	},
-- 	config = require("ui.cursor"),
-- }
ui["mrjones2014/smart-splits.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("ui.splits"),
}
ui["folke/edgy.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("ui.edgy"),
}
ui["folke/todo-comments.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = require("ui.todo"),
	dependencies = "nvim-lua/plenary.nvim",
}
ui["dstein64/nvim-scrollview"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = require("ui.scrollview"),
}

return ui
