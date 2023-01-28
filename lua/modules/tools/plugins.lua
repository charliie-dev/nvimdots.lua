local tools = {}

tools["sudormrfbin/cheatsheet.nvim"] = {
	lazy = true,
	cmd = "Cheatsheet",
	dependencies = {
		{ "nvim-telescope/telescope.nvim" },
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-lua/popup.nvim" },
	},
	config = function()
		require("modules.tools.cheatsheet")
	end,
}
tools["ja-ford/delaytrain.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.tools.delaytrain")
	end,
}
tools["monaqa/dial.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("modules.tools.dial")
	end,
}
-- tools["ThePrimeagen/git-worktree.nvim"] = {
-- 	lazy = true,
-- 	event = "BufReadPost",
-- 	requires = {
-- 		{ "nvim-lua/plenary.nvim" },
-- 		{ "nvim-telescope/telescope.nvim" },
-- 	},
-- 	config = function()
-- 		require("modules.tools.git-worktree")
-- 	end,
-- }
tools["samodostal/image.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	dependencies = { "nvim-lua/plenary.nvim", "m00qek/baleia.nvim" },
	config = function()
		require("modules.tools.image")
	end,
}
tools["mrjones2014/legendary.nvim"] = {
	lazy = true,
	cmd = "Legendary",
	dependencies = {
		{ "kkharji/sqlite.lua" },
		{
			"stevearc/dressing.nvim",
			event = "VeryLazy",
			config = function()
				require("modules.tools.dressing")
			end,
		},
		-- Please don't remove which-key.nvim otherwise you need to set timeoutlen=300 at `lua/core/options.lua`
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			config = function()
				require("modules.tools.whichkey")
			end,
		},
	},
	config = function()
		require("modules.tools.legendary")
	end,
}
tools["AckslD/nvim-neoclip.lua"] = {
	lazy = true,
	event = { "CmdlineEnter", "TextYankPost" },
	dependencies = {
		{ "kkharji/sqlite.lua" },
		{ "nvim-telescope/telescope.nvim" },
	},
	config = function()
		require("modules.tools.neoclip")
	end,
}
tools["nvim-tree/nvim-tree.lua"] = {
	lazy = true,
	cmd = {
		"NvimTreeToggle",
		"NvimTreeOpen",
		"NvimTreeFindFile",
		"NvimTreeFindFileToggle",
		"NvimTreeRefresh",
	},
	config = function()
		require("modules.tools.nvim-tree")
	end,
}
tools["stevearc/oil.nvim"] = {
	lazy = true,
	cmd = "Oil",
	config = function()
		require("modules.tools.oil")
	end,
}

-- tools["narutoxy/silicon.lua"] = {
-- 	lazy = true,
-- 	-- cmd = "Silicon",
-- 	event = "BufReadPost",
-- 	requires = { "nvim-lua/plenary.nvim" },
-- 	config = function()
-- 		require("modules.tools.silicon")
-- 	end,
-- }
tools["bennypowers/nvim-regexplainer"] = {
	lazy = true,
	cmd = {
		"RegexplainerShowSplit",
		"RegexplainerShowPopup",
		"RegexplainerHide",
		"RegexplainerToggle",
	},
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("modules.editor.regexplainer")
	end,
}
tools["ibhagwan/smartyank.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.tools.smartyank")
	end,
}
tools["michaelb/sniprun"] = {
	lazy = true,
	build = "bash ./install.sh",
	cmd = { "SnipRun" },
	config = function()
		require("modules.tools.sniprun")
	end,
}
tools["aserowy/tmux.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.tools.tmux")
	end,
}
tools["akinsho/toggleterm.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.tools.toggleterm")
	end,
}
tools["folke/trouble.nvim"] = {
	lazy = true,
	cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
	config = function()
		require("modules.tools.trouble")
	end,
}
tools["samjwill/nvim-unception"] = {
	lazy = true,
	event = "BufReadPost",
	config = function()
		require("modules.tools.unception")
	end,
}
tools["gelguy/wilder.nvim"] = {
	lazy = true,
	event = { "CmdlineEnter" },
	dependencies = { { "romgrk/fzy-lua-native" } },
	config = function()
		require("modules.tools.wilder")
	end,
}

----------------------------------------------------------------------
--                        Telescope Plugins                         --
----------------------------------------------------------------------
tools["nvim-telescope/telescope.nvim"] = {
	lazy = true,
	cmd = "Telescope",
	dependencies = {
		{ "nvim-tree/nvim-web-devicons" },
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-lua/popup.nvim" },
		{ "LinArcX/telescope-env.nvim" },
		{ "debugloop/telescope-undo.nvim" },
		{ "nvim-telescope/telescope-live-grep-args.nvim" },
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		{ "nvim-telescope/telescope-frecency.nvim", dependencies = {
			{ "kkharji/sqlite.lua" },
		} },
		{
			"ahmedkhalf/project.nvim",
			event = "BufReadPost",
			config = function()
				require("modules.tools.project")
			end,
		},
	},
	config = function()
		require("modules.tools.telescope")
	end,
}

----------------------------------------------------------------------
--                           DAP Plugins                            --
----------------------------------------------------------------------
tools["mfussenegger/nvim-dap"] = {
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
	config = function()
		require("modules.tools.dap")
	end,
	dependencies = {
		"rcarriga/nvim-dap-ui",
		config = function()
			require("modules.tools.dap._dapui")
		end,
	},
}

return tools
