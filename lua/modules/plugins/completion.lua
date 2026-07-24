local completion = {}

completion["mason-org/mason.nvim"] = {
	lazy = true,
	cmd = {
		"Mason",
		"MasonInstall",
		"MasonUninstall",
		"MasonUninstallAll",
		"MasonUpdate",
		"MasonLog",
	},
	config = require("completion.mason").setup,
}

completion["neovim/nvim-lspconfig"] = {
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	config = require("completion.lsp"),
	dependencies = {
		{ "b0o/schemastore.nvim" },
	},
}
-- mason-lspconfig only supplies the lspconfig -> package mappings; the LSP
-- resolver degrades to $PATH discovery when it (or mason.nvim) is absent.
-- Deliberately NOT a dependency of nvim-lspconfig: lazy.nvim loads dependencies
-- together with the parent, and a fully provisioned session must not pay Mason
-- on the BufReadPre tick — the resolver requires it on demand (module loader).
-- The cmd trigger restores :LspInstall/:LspUninstall (registered only inside
-- setup(), which nothing reaches on the BufReadPre/load tick); both load paths
-- funnel through the config below exactly once.
completion["mason-org/mason-lspconfig.nvim"] = {
	lazy = true,
	cmd = { "LspInstall", "LspUninstall" },
	config = require("completion.mason-lspconfig-setup"),
}
completion["nvimdev/lspsaga.nvim"] = {
	lazy = true,
	event = "LspAttach",
	config = require("completion.lspsaga"),
	dependencies = "nvim-tree/nvim-web-devicons",
}
completion["rachartier/tiny-inline-diagnostic.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	priority = 1000,
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

completion["saghen/blink.cmp"] = {
	lazy = true,
	event = { "VeryLazy", "InsertEnter", "CmdlineEnter" },
	config = require("completion.blink"),
	version = "*",
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			build = "make install_jsregexp",
			config = require("completion.luasnip"),
			dependencies = "rafamadriz/friendly-snippets",
		},
		"mikavilpas/blink-ripgrep.nvim",
		"bydlw98/blink-cmp-env",
		"disrupted/blink-cmp-conventional-commits",
		"xzbdmw/colorful-menu.nvim",
	},
	opts_extend = { "sources.default" },
}

-- completion["barreiroleo/ltex_extra.nvim"] = {
-- 	lazy = true,
-- 	ft = "tex",
-- }

-- Adding *nvim config dir*, *nvim runtime dir*, *all plugin dir(with /lua dir)* to get
-- hover docs and function signatures, but it takes too much time to load all dirs, use it if needed.
completion["folke/lazydev.nvim"] = {
	lazy = true,
	ft = "lua",
	config = require("completion.lazydev"),
}

return completion
