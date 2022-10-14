local completion = {}

completion["neovim/nvim-lspconfig"] = {
	opt = true,
	event = "BufReadPre",
	after = "mason.nvim",
	config = function()
		require("modules.completion.lsp")
	end,
}
completion["williamboman/mason.nvim"] = {
	opt = false,
	-- event = "BufReadPre",
	module = { "mason", "mason-registry" },
	requires = {
		{
			"williamboman/mason-lspconfig.nvim",
			module = "mason-lspconfig",
		},
	},
}
completion["WhoIsSethDaniel/mason-tool-installer.nvim"] = {
	opt = true,
	after = "mason.nvim",
	cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
	module = "mason-tool-installer",
	config = function()
		require("modules.completion.mason-install")
	end,
}
completion["jose-elias-alvarez/null-ls.nvim"] = {
	opt = true,
	event = "BufReadPre",
	config = function()
		require("modules.completion.null-ls")
	end,
}
completion["glepnir/lspsaga.nvim"] = {
	opt = true,
	event = "LspAttach",
	config = function()
		require("modules.completion.saga")
	end,
}
completion["ray-x/lsp_signature.nvim"] = {
	opt = true,
	after = "nvim-lspconfig",
}
completion["https://git.sr.ht/~whynothugo/lsp_lines.nvim"] = {
	opt = true,
	after = "nvim-lspconfig",
	config = function()
		require("modules.completion.lines")
	end,
}
completion["hrsh7th/nvim-cmp"] = {
	event = "BufReadPost",
	after = { "LuaSnip" },
	-- module = "cmp",
	requires = {
		{ "onsails/lspkind.nvim", opt = true, module = "lspkind" },
		{ "lukas-reineke/cmp-under-comparator", opt = true, module = "cmp-under-comparator" },
		{ "saadparwaiz1/cmp_luasnip", after = { "nvim-cmp", "LuaSnip" } },
		{ "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp", opt = true },
		{ "hrsh7th/cmp-nvim-lua", after = "nvim-cmp", opt = true },
		{ "andersevenrud/cmp-tmux", after = "nvim-cmp", opt = true },
		{ "hrsh7th/cmp-path", after = "nvim-cmp", opt = true },
		{ "hrsh7th/cmp-buffer", after = "nvim-cmp", opt = true },
		{ "kdheepak/cmp-latex-symbols", after = "nvim-cmp", opt = true },
		{ "ray-x/cmp-treesitter", after = "nvim-cmp", opt = true },
		-- { "f3fora/cmp-spell", after = "cmp-path" },
	},
	config = function()
		require("modules.completion.cmp")
	end,
}
completion["L3MON4D3/LuaSnip"] = {
	opt = true,
	event = "BufReadPost",
	module = {
		"luasnip.loaders.from_vscode",
		"luasnip.loaders.from_lua",
		"luasnip.loaders.from_snipmate",
	},
	requires = { "rafamadriz/friendly-snippets", event = "InsertEnter" },
	config = function()
		require("modules.completion.luasnip")
	end,
}
completion["windwp/nvim-autopairs"] = {
	after = "nvim-cmp",
	config = function()
		require("modules.completion.autopairs")
	end,
}
completion["zbirenbaum/copilot.lua"] = {
	-- The options in cmp panel is still slow with VimEnter, so use BufReadPre for faster startup time.
	-- event = "VimEnter",
	event = "BufReadPre",
	module = {
		"copilot",
		"copilot.util",
	},
	config = function()
		vim.schedule(function()
			require("modules.completion.copilot")
		end)
	end,
}
completion["zbirenbaum/copilot-cmp"] = {
	after = "copilot.lua",
	module = "copilot_cmp",
	requires = "hrsh7th/nvim-cmp",
	config = function()
		require("modules.completion.copilot-cmp")
	end,
}

-- Adding *nvim config dir*, *nvim runtime dir*, *all plugin dir(with /lua dir)* to get
-- hover docs and function signatures, but it takes too much time to load all dirs, use it if needed.
-- completion["folke/lua-dev.nvim"] = {
-- 	opt = true,
-- 	module = "lua-dev",
-- }

return completion
