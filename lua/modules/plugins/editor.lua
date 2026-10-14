local editor = {}

editor["sindrets/diffview.nvim"] = {
	lazy = true,
	cmd = { "DiffviewOpen", "DiffviewClose" },
	config = require("modules.configs.editor.diffview"),
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
editor["nvim-mini/mini.align"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	-- Also load on the first alignment key: before the first idle, `gea` was a native `ge` motion
	-- followed by `a` (append). Keep in sync with the mappings in configs/editor/align.lua.
	keys = {
		{ "gea", mode = { "n", "x" }, desc = "edit: Align" },
		{ "geA", mode = { "n", "x" }, desc = "edit: Align with preview" },
	},
	config = require("modules.configs.editor.align"),
}
editor["nvim-mini/mini.cursorword"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = require("modules.configs.editor.cursorword"),
}
editor["nvim-mini/mini.surround"] = {
	lazy = true,
	event = { "BufReadPost", "BufNewFile" },
	version = false,
	config = require("modules.configs.editor.surround"),
}
editor["folke/flash.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("modules.configs.editor.flash"),
}
editor["olimorris/persisted.nvim"] = {
	lazy = true,
	cmd = "Persisted",
	config = require("modules.configs.editor.persisted"),
}
editor["lambdalisue/suda.vim"] = {
	lazy = true,
	cmd = { "SudaRead", "SudaWrite" },
	init = require("modules.configs.editor.suda"),
}
editor["brenoprata10/nvim-highlight-colors"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("modules.configs.editor.highlight-colors"),
}
editor["MagicDuck/grug-far.nvim"] = {
	lazy = true,
	cmd = "GrugFar",
	config = require("modules.configs.editor.grug-far"),
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
	-- TextYankPost loads it at the first yank or delete, before a paste can need it. Not lazy `keys`:
	-- replaying `p` would drop the count and register of the first paste.
	event = { "CursorHold", "CursorHoldI", "TextYankPost" },
	config = require("modules.configs.editor.smart-paste"),
}

editor["charliie-dev/hmts.nvim"] = {
	lazy = true,
	branch = "main",
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
	config = require("modules.configs.editor.neogen"),
}

editor["nvim-treesitter/nvim-treesitter"] = {
	-- lazy = true,
	lazy = false,
	-- event = "BufReadPre",
	branch = "main",
	build = ":TSUpdate",
	config = require("modules.configs.editor.treesitter"),
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
	config = require("modules.configs.editor.ai_textobj"),
}

editor["nvim-treesitter/nvim-treesitter-textobjects"] = {
	lazy = false,
	branch = "main",
	config = require("modules.configs.editor.ts-textobjects"),
}

editor["windwp/nvim-ts-autotag"] = {
	lazy = false,
	config = require("modules.configs.editor.ts-autotag"),
}

editor["HiPhish/rainbow-delimiters.nvim"] = {
	lazy = false,
	config = require("modules.configs.editor.rainbow_delims"),
}

editor["nvim-treesitter/nvim-treesitter-context"] = {
	lazy = false,
	config = require("modules.configs.editor.ts-context"),
}

return editor
