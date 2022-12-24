local tools = {}
local cmd = vim.api.nvim_command

tools["nvim-lua/plenary.nvim"] = {
	opt = true,
	module = "plenary",
}
tools["dstein64/vim-startuptime"] = {
	opt = true,
	cmd = "StartupTime",
}
tools["kkharji/sqlite.lua"] = {
	opt = true,
	module = "sqlite",
}
tools["sudormrfbin/cheatsheet.nvim"] = {
	opt = true,
	cmd = "Cheatsheet",
	requires = {
		{ "nvim-telescope/telescope.nvim" },
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-lua/popup.nvim" },
	},
	config = function()
		require("modules.tools.cheatsheet")
	end,
}
tools["ja-ford/delaytrain.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.tools.delaytrain")
	end,
}
tools["monaqa/dial.nvim"] = {
	opt = true,
	event = "BufReadPost",
	module = {
		"dial.augend",
		"dial.config",
	},
	requires = { "nvim-lua/plenary.nvim" },
	config = function()
		require("modules.tools.dial")
	end,
}
tools["ThePrimeagen/git-worktree.nvim"] = {
	opt = true,
	event = "BufReadPost",
	module = "git-worktree",
	requires = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-telescope/telescope.nvim" },
	},
	config = function()
		require("modules.tools.git-worktree")
	end,
}
tools["samodostal/image.nvim"] = {
	opt = true,
	event = "BufReadPost",
	requires = { "nvim-lua/plenary.nvim", "m00qek/baleia.nvim" },
	config = function()
		require("modules.tools.image")
	end,
}
tools["mrjones2014/legendary.nvim"] = {
	opt = true,
	cmd = "Legendary",
	requires = {
		"stevearc/dressing.nvim",
		"kkharji/sqlite.lua",
		"folke/which-key.nvim",
	},
	config = function()
		require("modules.tools.legendary")
	end,
}
tools["AckslD/nvim-neoclip.lua"] = {
	opt = true,
	event = { "CmdlineEnter", "TextYankPost" },
	module = { "neoclip" },
	requires = {
		{ "kkharji/sqlite.lua" },
		{ "nvim-telescope/telescope.nvim" },
	},
	config = function()
		require("modules.tools.neoclip")
	end,
}
tools["nvim-tree/nvim-tree.lua"] = {
	opt = true,
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
tools["bennypowers/nvim-regexplainer"] = {
	opt = true,
	cmd = { "RegexplainerToggle", "RegexplainerShow" },
	requires = {
		"nvim-treesitter/nvim-treesitter",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("modules.tools.regexplainer")
	end,
}
-- tools["narutoxy/silicon.lua"] = {
-- 	opt = true,
-- 	-- cmd = "Silicon",
-- 	event = "BufReadPost",
-- 	requires = { "nvim-lua/plenary.nvim" },
-- 	config = function()
-- 		require("modules.tools.silicon")
-- 	end,
-- }
tools["ibhagwan/smartyank.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.tools.smartyank")
	end,
}
tools["michaelb/sniprun"] = {
	opt = true,
	run = "bash ./install.sh",
	cmd = { "SnipRun", "'<,'>SnipRun" },
	config = function()
		require("modules.tools.sniprun")
	end,
}
tools["aserowy/tmux.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.tools.tmux")
	end,
}
tools["akinsho/toggleterm.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.tools.toggleterm")
	end,
}
tools["folke/trouble.nvim"] = {
	opt = true,
	cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
	requires = "kyazdani42/nvim-web-devicons",
	after = "null-ls.nvim",
	config = function()
		require("modules.tools.trouble")
	end,
}
tools["samjwill/nvim-unception"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.tools.unception")
	end,
}
-- Please don't remove which-key.nvim otherwise you need to set timeoutlen=300 at `lua/core/options.lua`
tools["folke/which-key.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = function()
		require("modules.tools.whichkey")
	end,
}
tools["gelguy/wilder.nvim"] = {
	event = { "CmdwinEnter", "CmdlineEnter" },
	module = "wilder",
	run = function()
		cmd([[packadd wilder.nvim]])
		cmd([[silent UpdateRemotePlugins]])
	end,
	requires = { "romgrk/fzy-lua-native", after = "wilder.nvim" },
	config = function()
		require("modules.tools.wilder")
	end,
}

----------------------------------------------------------------------
--                        Telescope Plugins                         --
----------------------------------------------------------------------
tools["nvim-telescope/telescope.nvim"] = {
	opt = true,
	module = "telescope",
	-- cmd = "Telescope",
	-- keys = "<leader>",
	event = "BufReadPost",
	wants = {
		-- "harpoon",
		"nvim-notify",
		"nvim-neoclip.lua",
		"git-worktree.nvim",
	},
	requires = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-lua/popup.nvim" },
	},
	config = function()
		require("modules.tools.telescope")
	end,
}
tools["nvim-telescope/telescope-fzf-native.nvim"] = {
	opt = true,
	run = "make",
	after = "telescope.nvim",
}
tools["ahmedkhalf/project.nvim"] = {
	opt = true,
	after = "telescope.nvim",
	config = function()
		require("modules.tools.project")
	end,
}
tools["nvim-telescope/telescope-frecency.nvim"] = {
	opt = true,
	after = "telescope.nvim",
	requires = { "kkharji/sqlite.lua" },
}
tools["jvgrootveld/telescope-zoxide"] = {
	opt = true,
	after = "telescope.nvim",
}
tools["LinArcX/telescope-env.nvim"] = {
	opt = true,
	cmd = "Telescope env",
	after = "telescope.nvim",
}
tools["nvim-telescope/telescope-live-grep-args.nvim"] = {
	opt = true,
	after = "telescope.nvim",
}
tools["debugloop/telescope-undo.nvim"] = {
	opt = true,
	after = "telescope.nvim",
}

----------------------------------------------------------------------
--                           DAP Plugins                            --
----------------------------------------------------------------------
tools["mfussenegger/nvim-dap"] = {
	opt = true,
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
	module = "dap",
	config = function()
		require("modules.tools.dap")
	end,
}
tools["rcarriga/nvim-dap-ui"] = {
	opt = true,
	after = "nvim-dap",
	config = function()
		require("modules.tools.dap._dapui")
	end,
}

return tools
