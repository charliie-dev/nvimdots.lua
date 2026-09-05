local ui = {}

ui["folke/snacks.nvim"] = {
	lazy = false,
	priority = 1000,
	config = require("modules.configs.ui.snacks"),
}
ui["akinsho/bufferline.nvim"] = {
	lazy = true,
	event = { "BufReadPre", "BufAdd", "BufNewFile" },
	config = require("modules.configs.ui.bufferline"),
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
ui["catppuccin/nvim"] = {
	lazy = false,
	priority = 1000,
	name = "catppuccin",
	config = require("modules.configs.ui.catppuccin"),
}
ui["lewis6991/gitsigns.nvim"] = {
	lazy = true,
	event = { "BufReadPost", "BufNewFile" },
	config = require("modules.configs.ui.gitsigns"),
}
ui["nvim-lualine/lualine.nvim"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = require("modules.configs.ui.lualine"),
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
-- ui["sphamba/smear-cursor.nvim"] = {
-- 	lazy = true,
-- 	event = {
-- 		"CursorMoved", --[[CursorMovedC,]]
-- 		"CursorMovedI",
-- 	},
-- 	config = require("modules.configs.ui.cursor"),
-- }
ui["mrjones2014/smart-splits.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("modules.configs.ui.splits"),
}
ui["folke/edgy.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("modules.configs.ui.edgy"),
}
ui["folke/todo-comments.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("modules.configs.ui.todo"),
	dependencies = { "nvim-lua/plenary.nvim" },
}
ui["dstein64/nvim-scrollview"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = require("modules.configs.ui.scrollview"),
}

return ui
