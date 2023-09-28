local ui = {}

ui["goolord/alpha-nvim"] = {
	lazy = true,
	event = "BufWinEnter",
	config = require("ui.alpha"),
}
ui["akinsho/bufferline.nvim"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = require("ui.bufferline"),
}
ui["Jint-lzxy/nvim"] = {
	lazy = false,
	branch = "refactor/syntax-highlighting",
	name = "catppuccin",
	config = require("ui.catppuccin"),
}
-- ui["sainnhe/everforest"] = {
-- lazy = true,
-- }
ui["j-hui/fidget.nvim"] = {
	lazy = true,
	branch = "legacy",
	event = "LspAttach",
	config = require("ui.fidget"),
}
-- ui["f-person/git-blame.nvim"] = {
-- 	lazy = true,
-- 	event = "BufReadPost",
-- 	config = require("ui.git-blame"),
-- }
ui["lewis6991/gitsigns.nvim"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("ui.gitsigns"),
}
-- ui["sainnhe/gruvbox-material"] = {
-- 	lazy = true,
-- 	config = require("ui.gruvbox-material"),
-- }
ui["ellisonleao/gruvbox.nvim"] = {
	lazy = true,
	config = require("ui.gruvbox"),
}
ui["lukas-reineke/indent-blankline.nvim"] = {
	main = "ibl",
	lazy = true,
	event = "BufReadPost",
	config = require("ui.indent-blankline"),
}
-- ui["rebelot/kanagawa.nvim"] = {
-- 	lazy = false,
-- 	config = require("ui.kanagawa"),
-- }
ui["hoob3rt/lualine.nvim"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = require("ui.lualine"),
}
ui["zbirenbaum/neodim"] = {
	lazy = true,
	commit = "9477da0",
	event = "LspAttach",
	config = require("ui.neodim"),
}
ui["karb94/neoscroll.nvim"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("ui.neoscroll"),
}
ui["rcarriga/nvim-notify"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("ui.notify"),
}
ui["folke/paint.nvim"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("ui.paint"),
}
ui["petertriho/nvim-scrollbar"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = require("ui.scrollbar"),
}
ui["folke/todo-comments.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = require("ui.todo-comments"),
	dependencies = "nvim-lua/plenary.nvim",
}
ui["itchyny/vim-highlighturl"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		vim.g.highlighturl_guifg = "#8AB4F8"
	end,
}

return ui
