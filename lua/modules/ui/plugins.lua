local ui = {}

ui["goolord/alpha-nvim"] = {
	opt = true,
	event = "BufWinEnter",
	config = function()
		require("modules.ui.alpha")
	end,
}
ui["akinsho/bufferline.nvim"] = {
	opt = true,
	tag = "*",
	event = "BufReadPost",
	config = function()
		require("modules.ui.bufferline")
	end,
}
ui["declancm/cinnamon.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.ui.cinnamon")
	end,
}
ui["NvChad/nvim-colorizer.lua"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.ui.colorizer")
	end,
}
ui["j-hui/fidget.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.ui.fidget")
	end,
}
ui["f-person/git-blame.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.ui.git-blame")
	end,
}
ui["lewis6991/gitsigns.nvim"] = {
	opt = true,
	event = { "BufReadPost", "BufNewFile" },
	requires = { "nvim-lua/plenary.nvim" },
	config = function()
		require("modules.ui.gitsigns")
	end,
}
-- ui["sainnhe/gruvbox-material"] = {
-- 	opt = true,
-- 	config = function()
-- 		require("modules.ui.gruvbox-material")
-- 	end,
-- }
-- ui["ellisonleao/gruvbox.nvim"] = {
-- 	opt = true,
-- 	config = function()
-- 		require("modules.ui.gruvbox")
-- 	end,
-- }
-- ui["sainnhe/everforest"] = {
-- 	opt = true,
-- }
ui["rebelot/kanagawa.nvim"] = {
	opt = false,
	config = function()
		require("modules.ui.kanagawa")
	end,
}
ui["kevinhwang91/nvim-hlslens"] = {
	opt = true,
	module = "hlslens",
	keys = { "/", "?", "*", "#" }, --'n', 'N', '*', '#', 'g'
	config = function()
		require("modules.ui.hlslens")
	end,
}
ui["lukas-reineke/indent-blankline.nvim"] = {
	opt = true,
	event = "BufReadPost",
	after = "nvim-treesitter",
	config = function()
		require("modules.ui.indent-blankline")
	end,
}
ui["hoob3rt/lualine.nvim"] = {
	opt = true,
	after = { "git-blame.nvim" },
	config = function()
		require("modules.ui.lualine")
	end,
}
ui["AckslD/messages.nvim"] = {
	opt = true,
	cmd = "Messages",
	config = function()
		require("modules.ui.messages")
	end,
}
ui["rcarriga/nvim-notify"] = {
	opt = true,
	event = "BufReadPre",
	module = "notify",
	config = function()
		require("modules.ui.notify")
	end,
}
ui["MunifTanjim/nui.nvim"] = {
	opt = true,
	module = "nui",
}
ui["kyazdani42/nvim-web-devicons"] = {
	opt = true,
	module = "nvim-web-devicons",
}
ui["anuvyklack/pretty-fold.nvim"] = {
	opt = true,
	after = { "nvim-treesitter" },
	config = function()
		require("modules.ui.pretty-fold")
	end,
}
ui["petertriho/nvim-scrollbar"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.ui.scrollbar")
	end,
}
ui["levouh/tint.nvim"] = {
	opt = true,
	event = { "CmdwinEnter", "CmdlineEnter" },
	config = function()
		require("modules.ui.tint")
	end,
}
ui["folke/todo-comments.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.ui.todo-comments")
	end,
}
ui["itchyny/vim-highlighturl"] = {
	opt = true,
	event = "BufReadPost",
}

return ui
