local ui = {}

ui["goolord/alpha-nvim"] = {
	lazy = true,
	event = "BufWinEnter",
	config = function()
		require("modules.ui.alpha")
	end,
}
ui["akinsho/bufferline.nvim"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = function()
		require("modules.ui.bufferline")
	end,
}
ui["catppuccin/nvim"] = {
	lazy = false,
	name = "catppuccin",
	config = function()
		require("modules.ui.catppuccin")
	end,
}
ui["j-hui/fidget.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.ui.fidget")
	end,
}
ui["f-person/git-blame.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.ui.git-blame")
	end,
}
ui["lewis6991/gitsigns.nvim"] = {
	lazy = true,
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require("modules.ui.gitsigns")
	end,
}
-- ui["sainnhe/gruvbox-material"] = {
-- lazy = true,
-- 	config = function()
-- 		require("modules.ui.gruvbox-material")
-- 	end,
-- }
-- ui["ellisonleao/gruvbox.nvim"] = {
-- lazy = true,
-- 	config = function()
-- 		require("modules.ui.gruvbox")
-- 	end,
-- }
-- ui["sainnhe/everforest"] = {
-- lazy = true,
-- }
-- ui["kevinhwang91/nvim-hlslens"] = {
-- 	lazy = true,
-- 	module = "hlslens",
-- 	keys = { "/", "?", "*", "#" }, --'n', 'N', '*', '#'
-- 	config = function()
-- 		require("modules.ui.hlslens")
-- 	end,
-- }
ui["lukas-reineke/indent-blankline.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.ui.indent-blankline")
	end,
}
-- ui["rebelot/kanagawa.nvim"] = {
-- 	lazy = false,
-- 	config = function()
-- 		require("modules.ui.kanagawa")
-- 	end,
-- }
ui["hoob3rt/lualine.nvim"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = function()
		require("modules.ui.lualine")
	end,
}
ui["zbirenbaum/neodim"] = {
	lazy = true,
	event = "LspAttach",
	config = function()
		require("modules.ui.neodim")
	end,
}
ui["karb94/neoscroll.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.ui.neoscroll")
	end,
}
ui["romainl/vim-cool"] = {
	lazy = true,
	event = { "CursorMoved", "InsertEnter" },
}
ui["rcarriga/nvim-notify"] = {
	lazy = true,
	event = "VeryLazy",
	config = function()
		require("modules.ui.notify")
	end,
}
-- ui["anuvyklack/pretty-fold.nvim"] = { -- not using fold ATM
-- 	lazy = true,
-- 	after = { "nvim-treesitter" },
-- 	config = function()
-- 		require("modules.ui.pretty-fold")
-- 	end,
-- }
ui["petertriho/nvim-scrollbar"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.ui.scrollbar")
	end,
}
-- ui["folke/styler.nvim"] = {
-- 	lazy = true,
-- 	event = "BufReadPost",
-- 	cmd = "Styler",
-- 	config = function()
-- 		require("modules.ui.styler")
-- 	end,
-- }
ui["folke/todo-comments.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.ui.todo-comments")
	end,
}
ui["itchyny/vim-highlighturl"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		vim.g.highlighturl_guifg = "#8AB4F8"
	end,
}

return ui
