local tool = {}

tool["monaqa/dial.nvim"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("modules.configs.tool.dial"),
}
tool["tpope/vim-fugitive"] = {
	lazy = true,
	cmd = { "Git", "G" },
}
tool["Bekaboo/dropbar.nvim"] = {
	lazy = false,
	config = require("modules.configs.tool.dropbar"),
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
tool["stevearc/oil.nvim"] = {
	lazy = false,
	config = require("modules.configs.tool.oil"),
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
tool["michaelb/sniprun"] = {
	lazy = true,
	-- If you see an error about a missing SnipRun executable,
	-- run `bash ./install.sh` inside `~/.local/share/nvim/lazy/sniprun/`.
	build = "bash ./install.sh",
	cmd = { "SnipRun", "SnipReset", "SnipInfo" },
	config = require("modules.configs.tool.sniprun"),
}
tool["stevearc/overseer.nvim"] = {
	lazy = true,
	cmd = {
		"OverseerRun",
		"OverseerShell",
		"OverseerToggle",
		"OverseerOpen",
		"OverseerClose",
		"OverseerTaskAction",
	},
	config = require("modules.configs.tool.overseer"),
}
tool["folke/trouble.nvim"] = {
	lazy = true,
	cmd = { "Trouble" },
	config = require("modules.configs.tool.trouble"),
}
tool["folke/which-key.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("modules.configs.tool.which-key"),
}
tool["charliie-dev/leaf.nvim"] = {
	cmd = { "Leaf" },
	dependencies = { "folke/snacks.nvim" },
}
tool["mikavilpas/yazi.nvim"] = {
	version = "*",
	lazy = true,
	cmd = { "Yazi" },
	config = require("modules.configs.tool.yazi"),
	dependencies = {
		{ "nvim-lua/plenary.nvim", lazy = true },
	},
}

tool["aaronhallaert/advanced-git-search.nvim"] = {
	lazy = true,
	cmd = { "AdvancedGitSearch" },
	config = function()
		require("advanced_git_search.snacks").setup({
			diff_plugin = "diffview",
			git_flags = { "-c", "delta.side-by-side=true" },
			entry_default_author_or_date = "author",
		})
	end,
	dependencies = {
		"folke/snacks.nvim",
		"tpope/vim-fugitive",
		"sindrets/diffview.nvim",
	},
}

-- tool["amitds1997/remote-nvim.nvim"] = {
-- 	lazy = true,
-- 	version = "*",
-- 	cmd = { "RemoteStart", "RemoteStop", "RemoteInfo", "RemoteCleanup", "RemoteConfigDel", "RemoteLog" },
-- 	dependencies = {
-- 		"nvim-lua/plenary.nvim",
-- 		"MunifTanjim/nui.nvim",
-- 		"nvim-telescope/telescope.nvim",
-- 	},
-- 	config = true,
-- }

----------------------------------------------------------------------
--                           DAP Plugins                            --
----------------------------------------------------------------------
tool["leoluz/nvim-dap-go"] = {
	ft = "go",
	config = require("modules.configs.tool.dap.dap-go"),
	dependencies = { "mfussenegger/nvim-dap" },
}
tool["mfussenegger/nvim-dap-python"] = {
	ft = "python",
	config = require("modules.configs.tool.dap.dap-python"),
	dependencies = { "mfussenegger/nvim-dap" },
}
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
	config = require("modules.configs.tool.dap"),
	dependencies = {
		{
			"rcarriga/nvim-dap-ui",
			dependencies = { "nvim-neotest/nvim-nio" },
			config = require("modules.configs.tool.dap.dapui"),
		},
	},
}

tool["trixnz/sops.nvim"] = {
	lazy = false,
}

return tool
