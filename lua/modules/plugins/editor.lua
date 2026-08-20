local editor = {}

editor["sindrets/diffview.nvim"] = {
	lazy = true,
	cmd = { "DiffviewOpen", "DiffviewClose" },
	config = require("editor.diffview"),
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
editor["nvim-mini/mini.align"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("editor.align"),
}
editor["nvim-mini/mini.cursorword"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = require("editor.cursorword"),
}
editor["nvim-mini/mini.surround"] = {
	lazy = true,
	event = { "BufReadPost", "BufNewFile" },
	version = false,
	config = require("editor.surround"),
}
editor["folke/flash.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("editor.flash"),
}
editor["olimorris/persisted.nvim"] = {
	lazy = true,
	cmd = "Persisted",
	config = require("editor.persisted"),
}
editor["lambdalisue/suda.vim"] = {
	lazy = true,
	cmd = { "SudaRead", "SudaWrite" },
	init = require("editor.suda"),
}
editor["brenoprata10/nvim-highlight-colors"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("editor.highlight-colors"),
}
editor["MagicDuck/grug-far.nvim"] = {
	lazy = true,
	cmd = "GrugFar",
	config = require("editor.grug-far"),
}

----------------------------------------------------------------------
--                  :treesitter related plugins                    --
----------------------------------------------------------------------
editor["jmbuhr/otter.nvim"] = {
	lazy = true,
	ft = { "toml", "markdown", "quarto", "org", "norg" },
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "toml", "markdown", "quarto", "org", "norg" },
			group = vim.api.nvim_create_augroup("EmbedToml", {}),
			callback = function()
				require("otter").activate()
			end,
		})
	end,
}

editor["nemanjamalesija/smart-paste.nvim"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("editor.smart-paste"),
}

editor["charliie-dev/hmts.nvim"] = {
	lazy = true,
	branch = "combined-fixes",
	ft = "nix",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
}

editor["bezhermoso/tree-sitter-ghostty"] = {
	lazy = true,
	ft = "ghostty",
	build = "make nvim_install",
}

editor["danymat/neogen"] = {
	lazy = true,
	cmd = "Neogen",
	config = require("editor.neogen"),
}

editor["nvim-treesitter/nvim-treesitter"] = {
	-- lazy = true,
	lazy = false,
	-- event = "BufReadPre",
	branch = "main",
	build = ":TSUpdate",
	config = require("editor.treesitter"),
	dependencies = {
		{
			"Hdoc1509/gh-actions.nvim",
			config = function()
				require("gh-actions.tree-sitter").setup()
			end,
		},
	},
}

editor["nvim-mini/mini.ai"] = {
	lazy = false,
	version = "*",
	config = require("editor.ai_textobj"),
}

editor["nvim-treesitter/nvim-treesitter-textobjects"] = {
	lazy = false,
	branch = "main",
	config = require("editor.ts-textobjects"),
}

editor["windwp/nvim-ts-autotag"] = {
	lazy = false,
	config = require("editor.ts-autotag"),
}

editor["HiPhish/rainbow-delimiters.nvim"] = {
	lazy = false,
	config = require("editor.rainbow_delims"),
}

editor["nvim-treesitter/nvim-treesitter-context"] = {
	lazy = false,
	config = require("editor.ts-context"),
}

return editor
