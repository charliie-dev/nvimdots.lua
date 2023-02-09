local tool = {}

tool["sudormrfbin/cheatsheet.nvim"] = {
	lazy = true,
	cmd = "Cheatsheet",
	config = require("tool.cheatsheet"),
	dependencies = {
		{ "nvim-telescope/telescope.nvim" },
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-lua/popup.nvim" },
	},
}
tool["ja-ford/delaytrain.nvim"] = {
	lazy = true,
	config = require("tool.delaytrain"),
	event = "BufReadPost",
}
tool["monaqa/dial.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = require("tool.dial"),
	dependencies = "nvim-lua/plenary.nvim",
}
tool["tpope/vim-fugitive"] = {
	lazy = true,
	cmd = { "Git", "G" },
}
tool["AckslD/nvim-neoclip.lua"] = {
	lazy = true,
	event = { "CmdlineEnter", "TextYankPost" },
	config = require("tool.neoclip"),
	dependencies = {
		{ "kkharji/sqlite.lua" },
		{ "nvim-telescope/telescope.nvim" },
	},
}
tool["nvim-tree/nvim-tree.lua"] = {
	lazy = true,
	cmd = {
		"NvimTreeToggle",
		"NvimTreeOpen",
		"NvimTreeFindFile",
		"NvimTreeFindFileToggle",
		"NvimTreeRefresh",
	},
	config = require("tool.nvim-tree"),
}
tool["stevearc/oil.nvim"] = {
	lazy = true,
	cmd = "Oil",
	config = require("tool.oil"),
}
tool["ibhagwan/smartyank.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = require("tool.smartyank"),
}
tool["michaelb/sniprun"] = {
	lazy = true,
	build = "bash ./install.sh",
	cmd = { "SnipRun" },
	config = require("tool.sniprun"),
}
tool["aserowy/tmux.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = require("tool.tmux"),
}
tool["akinsho/toggleterm.nvim"] = {
	lazy = true,
	event = "UIEnter",
	config = require("tool.toggleterm"),
}
tool["folke/trouble.nvim"] = {
	lazy = true,
	cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
	config = require("tool.trouble"),
}
tool["samjwill/nvim-unception"] = {
	lazy = true,
	event = "UIEnter",
	config = require("tool.unception"),
}
-- Please don't remove which-key.nvim otherwise you need to set timeoutlen=300 at `lua/core/options.lua`
tool["folke/which-key.nvim"] = {
	event = "VeryLazy",
	config = require("tool.which-key"),
}
tool["gelguy/wilder.nvim"] = {
	lazy = true,
	event = "CmdlineEnter",
	config = require("tool.wilder"),
	dependencies = "romgrk/fzy-lua-native",
}

----------------------------------------------------------------------
--                        Telescope Plugins                         --
----------------------------------------------------------------------
tool["nvim-telescope/telescope.nvim"] = {
	lazy = true,
	cmd = "Telescope",
	config = require("tool.telescope"),
	dependencies = {
		{ "nvim-tree/nvim-web-devicons" },
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-lua/popup.nvim" },
		{ "LinArcX/telescope-env.nvim" },
		{
			"ahmedkhalf/project.nvim",
			event = "BufReadPost",
			config = require("tool.project"),
		},
		{ "debugloop/telescope-undo.nvim" },
		{ "nvim-telescope/telescope-live-grep-args.nvim" },
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		{ "nvim-telescope/telescope-frecency.nvim", dependencies = {
			{ "kkharji/sqlite.lua" },
		} },
	},
}

----------------------------------------------------------------------
--                           DAP Plugins                            --
----------------------------------------------------------------------
tool["mfussenegger/nvim-dap"] = {
	lazy = true,
	cmd = {
		"DapSetLogLevel",
		"DapShowLog",
		"DapContinue",
		"DapToggleBreakpoint",
		"DapToggleRepl",
		"DapStepOver",
		"DapStepInto",
		"DapStepOut",
		"DapTerminate",
	},
	config = require("tool.dap"),
	dependencies = {
		{
			"rcarriga/nvim-dap-ui",
			config = require("tool.dap.dapui"),
		},
	},
}

return tool
