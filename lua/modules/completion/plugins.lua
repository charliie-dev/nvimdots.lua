local completion = {}

completion["neovim/nvim-lspconfig"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = function()
		require("modules.completion.lsp")
	end,
	dependencies = {
		{ "ray-x/lsp_signature.nvim" },
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			config = function()
				require("modules.completion.mason-install")
			end,
		},
		{
			"glepnir/lspsaga.nvim",
			config = function()
				require("modules.completion.saga")
			end,
		},
		{
			"jose-elias-alvarez/null-ls.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
				require("modules.completion.null-ls")
			end,
		},
	},
}
completion["hrsh7th/nvim-cmp"] = {
	lazy = true,
	event = "InsertEnter",
	config = function()
		require("modules.completion.Cmp")
	end,
	dependencies = {
		{ "onsails/lspkind.nvim" },
		{ "lukas-reineke/cmp-under-comparator" },
		{ "saadparwaiz1/cmp_luasnip" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-nvim-lua" },
		{ "andersevenrud/cmp-tmux" },
		{ "hrsh7th/cmp-path" },
		{ "hrsh7th/cmp-buffer" },
		{ "kdheepak/cmp-latex-symbols" },
		{ "ray-x/cmp-treesitter" },
		{ "f3fora/cmp-spell" },
		{
			"L3MON4D3/LuaSnip",
			dependencies = { "rafamadriz/friendly-snippets" },
			config = function()
				require("modules.completion.Luasnip")
			end,
		},
		{
			"windwp/nvim-autopairs",
			config = function()
				require("modules.completion.autopairs")
			end,
		},
	},
}
completion["zbirenbaum/copilot.lua"] = {
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("modules.completion.copilot")
	end,
	dependencies = {
		{
			"zbirenbaum/copilot-cmp",
			config = function()
				require("modules.completion.copilot-cmp")
			end,
		},
	},
}
completion["barreiroleo/ltex_extra.nvim"] = {
	lazy = true,
	ft = "tex",
}

-- Adding *nvim config dir*, *nvim runtime dir*, *all plugin dir(with /lua dir)* to get
-- hover docs and function signatures, but it takes too much time to load all dirs, use it if needed.
-- completion["folke/neodev.nvim"] = {
-- 	opt = true,
-- 	module = "neodev",
-- }

return completion
