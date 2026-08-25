local completion = {}

completion["neovim/nvim-lspconfig"] = {
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	config = require("completion.lsp"),
	dependencies = { "b0o/schemastore.nvim" },
}
completion["nvimdev/lspsaga.nvim"] = {
	lazy = true,
	event = "LspAttach",
	config = require("completion.lspsaga"),
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
completion["rachartier/tiny-inline-diagnostic.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	config = require("completion.tiny-inline-diagnostic"),
}
completion["stevearc/conform.nvim"] = {
	lazy = true,
	event = "BufWritePre",
	cmd = { "ConformInfo", "Format", "FormatToggle", "FormatterToggleFt" },
	config = require("completion.conform"),
}
completion["mfussenegger/nvim-lint"] = {
	lazy = true,
	event = { "BufWritePost", "BufReadPost" },
	config = require("completion.nvim-lint"),
}
completion["charliie-dev/muster.nvim"] = {
	event = { "BufReadPost", "BufNewFile" },
	cmd = "Muster",
	dependencies = {
		"neovim/nvim-lspconfig",
		"stevearc/conform.nvim",
		"mfussenegger/nvim-lint",
		"mfussenegger/nvim-dap",
	},
	config = require("completion.muster"),
}

completion["saghen/blink.cmp"] = {
	lazy = true,
	event = { "VeryLazy", "InsertEnter", "CmdlineEnter" },
	branch = "main",
	build = function()
		require("blink.cmp").build():pwait()
	end,
	config = require("completion.blink"),
	dependencies = {
		"saghen/blink.lib",
		{
			"L3MON4D3/LuaSnip",
			build = "make install_jsregexp",
			config = require("completion.luasnip"),
			dependencies = { "rafamadriz/friendly-snippets" },
		},
		"mikavilpas/blink-ripgrep.nvim",
		"bydlw98/blink-cmp-env",
		"disrupted/blink-cmp-conventional-commits",
		"xzbdmw/colorful-menu.nvim",
	},
	opts_extend = { "sources.default" },
}

-- Adding *nvim config dir*, *nvim runtime dir*, *all plugin dir(with /lua dir)* to get
-- hover docs and function signatures, but it takes too much time to load all dirs, use it if needed.
completion["folke/lazydev.nvim"] = {
	lazy = true,
	ft = "lua",
	config = require("completion.lazydev"),
}

return completion
