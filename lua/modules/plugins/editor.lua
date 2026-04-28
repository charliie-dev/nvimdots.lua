local editor = {}

-- editor["m4xshen/autoclose.nvim"] = {
-- 	lazy = true,
-- 	event = "InsertEnter",
-- 	config = require("editor.autoclose"),
-- }
-- editor["s1n7ax/nvim-comment-frame"] = {
-- 	lazy = true,
-- 	event = { "CursorHold", "CursorHoldI" },
-- 	config = require("editor.comment-frame"),
-- 	dependencies = "nvim-treesitter/nvim-treesitter",
-- }
editor["sindrets/diffview.nvim"] = {
	lazy = true,
	cmd = { "DiffviewOpen", "DiffviewClose" },
	config = require("editor.diffview"),
}
editor["echasnovski/mini.align"] = {
	lazy = true,
	keys = { { "gea" }, { "geA" } },
	config = require("editor.align"),
}
editor["echasnovski/mini.cursorword"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = require("editor.cursorword"),
}
editor["echasnovski/mini.surround"] = {
	lazy = true,
	event = "BufReadPost",
	version = false,
	config = require("editor.surround"),
}
-- NOTE: `flash.nvim` is a powerful plugin that can be used as partial or complete replacements for:
--  > `hop.nvim`,
--  > `wilder.nvim`
--  > `nvim-treehopper`
-- Considering its steep learning curve as well as backward compatibility issues...
--  > We have no plan to remove the above plugins for the time being.
-- But as usual, you can always tweak the plugin to your liking.
editor["folke/flash.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("editor.flash"),
}
editor["olimorris/persisted.nvim"] = {
	lazy = true,
	cmd = {
		"SessionToggle",
		"SessionStart",
		"SessionStop",
		"SessionSave",
		"SessionLoad",
		"SessionLoadLast",
		"SessionLoadFromFile",
		"SessionDelete",
	},
	config = require("editor.persisted"),
}
editor["lambdalisue/suda.vim"] = {
	lazy = true,
	cmd = { "SudaRead", "SudaWrite" },
	init = require("editor.suda"),
}
editor["brenoprata10/nvim-highlight-colors"] = {
	lazy = true,
	event = "BufReadPost",
	config = require("editor.highlight-colors"),
}
editor["MagicDuck/grug-far.nvim"] = {
	lazy = true,
	cmd = "GrugFar",
	config = require("editor.grug-far"),
}
-- editor["joshuadanpeterson/typewriter.nvim"] = {
-- 	lazy = true,
-- 	event = "BufReadPre",
-- 	dependencies = "nvim-treesitter/nvim-treesitter",
-- 	config = require("editor.typewriter"),
-- 	init = function()
-- 		require("typewriter.commands").enable_typewriter_mode()
-- 	end,
-- }

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
			group = vim.api.nvim_create_augroup("OtterActivate", {}),
			callback = function()
				require("otter").activate()
			end,
		})
	end,
}

editor["nemanjamalesija/smart-paste.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = require("editor.smart-paste"),
}

editor["nvim-treesitter/nvim-treesitter"] = {
	-- lazy = true,
	lazy = false,
	-- event = "BufReadPre",
	branch = "main",
	init = function()
		require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
			local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
			local filename = vim.fn.fnamemodify(filepath, ":t")
			return string.match(filename, ".*mise.*%.toml$") ~= nil
		end, { force = true, all = false })
	end,
	build = function()
		if #vim.api.nvim_list_uis() > 0 then
			local parsers = vim.tbl_keys(require("core.settings").treesitter_deps)
			table.sort(parsers)
			require("nvim-treesitter").update(parsers, { summary = true })
		end
	end,
	config = require("editor.treesitter"),
	dependencies = {
		{ "charliie-dev/hmts.nvim", branch = "combined-fixes", ft = "nix" },
		{ "ravsii/tree-sitter-d2", ft = "d2", build = "make nvim-install" },
		{ "bezhermoso/tree-sitter-ghostty", ft = "ghostty", build = "make nvim_install" },
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
		-- {
		-- 	"andymass/vim-matchup",
		-- 	init = require("editor.matchup"),
		-- },
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
			"echasnovski/mini.ai",
			version = "*",
			config = require("editor.ai_textobj"),
		},
		{
			"danymat/neogen",
			cmd = "Neogen",
			config = require("editor.neogen"),
		},
	},
}

return editor
