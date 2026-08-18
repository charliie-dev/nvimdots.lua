local editor = {}

editor["sindrets/diffview.nvim"] = {
	lazy = true,
	cmd = { "DiffviewOpen", "DiffviewClose" },
	config = require("editor.diffview"),
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
	dependencies = "nvim-treesitter/nvim-treesitter",
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
	dependencies = "nvim-treesitter/nvim-treesitter",
}

editor["ravsii/tree-sitter-d2"] = {
	lazy = true,
	ft = "d2",
	build = "make nvim-install",
	dependencies = "nvim-treesitter/nvim-treesitter",
	init = function()
		vim.filetype.add({
			extension = {
				d2 = function()
					return "d2", function(bufnr)
						vim.bo[bufnr].commentstring = "# %s"
					end
				end,
			},
		})
	end,
}

editor["bezhermoso/tree-sitter-ghostty"] = {
	lazy = true,
	ft = "ghostty",
	build = "make nvim_install",
	dependencies = "nvim-treesitter/nvim-treesitter",
}

editor["danymat/neogen"] = {
	lazy = true,
	cmd = "Neogen",
	dependencies = "nvim-treesitter/nvim-treesitter",
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
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			branch = "main",
			config = require("editor.ts-textobjects"),
		},
		{
			"windwp/nvim-ts-autotag",
			config = require("editor.ts-autotag"),
		},
		{
			"HiPhish/rainbow-delimiters.nvim",
			config = require("editor.rainbow_delims"),
		},
		{
			"nvim-treesitter/nvim-treesitter-context",
			config = require("editor.ts-context"),
		},
		{
			"nvim-mini/mini.ai",
			version = "*",
			config = require("editor.ai_textobj"),
		},
	},
}

return editor
