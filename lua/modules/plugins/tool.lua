local tool = {}
local settings = require("core.settings")

tool["monaqa/dial.nvim"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("tool.dial"),
	dependencies = "nvim-lua/plenary.nvim",
}
tool["tpope/vim-fugitive"] = {
	lazy = true,
	cmd = { "Git", "G" },
}
tool["Bekaboo/dropbar.nvim"] = {
	lazy = false,
	config = require("tool.dropbar"),
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
tool["stevearc/oil.nvim"] = {
	lazy = true,
	cmd = "Oil",
	config = require("tool.oil"),
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
tool["michaelb/sniprun"] = {
	lazy = true,
	-- If you see an error about a missing SnipRun executable,
	-- run `bash ./install.sh` inside `~/.local/share/nvim/site/lazy/sniprun/`.
	build = "bash ./install.sh",
	cmd = { "SnipRun", "SnipReset", "SnipInfo" },
	config = require("tool.sniprun"),
}
tool["stevearc/overseer.nvim"] = {
	lazy = true,
	cmd = {
		"OverseerRun",
		"OverseerToggle",
		"OverseerOpen",
		"OverseerClose",
		"OverseerInfo",
		"OverseerBuild",
		"OverseerQuickAction",
		"OverseerTaskAction",
	},
	config = require("tool.overseer"),
}
tool["folke/trouble.nvim"] = {
	lazy = true,
	cmd = { "Trouble" },
	config = require("tool.trouble"),
}
tool["folke/which-key.nvim"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("tool.which-key"),
}
tool["mikavilpas/yazi.nvim"] = {
	version = "*",
	lazy = true,
	cmd = { "Yazi" },
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
		"tpope/vim-fugitive",
		"sindrets/diffview.nvim",
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
		{ "jay-babu/mason-nvim-dap.nvim" },
		{
			"rcarriga/nvim-dap-ui",
			dependencies = "nvim-neotest/nvim-nio",
			config = require("tool.dap.dapui"),
		},
	},
}

return tool
