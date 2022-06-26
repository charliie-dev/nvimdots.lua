local Plug = vim.fn["plug#"]

vim.call("plug#begin", "~/.config/nvim/plugged")

-- Fundamentals {{{
Plug("junegunn/vim-plug")

-- Plug 'antoinemadec/FixCursorHold.nvim'
-- Plug("andymass/vim-matchup")
Plug("Pocco81/AutoSave.nvim")
Plug("SmiteshP/nvim-navic")
Plug("ThePrimeagen/harpoon")
Plug("akinsho/bufferline.nvim")
Plug("aserowy/tmux.nvim")
Plug("dstein64/vim-startuptime")
Plug("farmergreg/vim-lastplace")
Plug("filipdutescu/renamer.nvim")
Plug("folke/todo-comments.nvim")
Plug("goolord/alpha-nvim")
Plug("karb94/neoscroll.nvim")
Plug("kevinhwang91/nvim-bqf")
Plug("kyazdani42/nvim-web-devicons")
Plug("lewis6991/impatient.nvim")
Plug("lukas-reineke/indent-blankline.nvim")
Plug("moll/vim-bbye")
Plug("nacro90/numb.nvim")
Plug("norcalli/nvim-colorizer.lua")
Plug("numToStr/Comment.nvim")
Plug("nvim-lua/plenary.nvim")
Plug("nvim-lua/popup.nvim")
Plug("nvim-lualine/lualine.nvim")
Plug("nvim-pack/nvim-spectre")
Plug("phaazon/hop.nvim")
Plug("rcarriga/nvim-notify")
Plug("tversteeg/registers.nvim")
Plug("ur4ltz/surround.nvim")
Plug("windwp/nvim-autopairs")
Plug("akinsho/toggleterm.nvim", { ["on"] = "ToggleTerm" })
Plug("gelguy/wilder.nvim", {
	run = function()
		vim.cmd([[let &rtp=&rtp]])
		vim.cmd([[UpdateRemotePlugins]])
	end,
})
Plug("ibhagwan/fzf-lua", { branch = "main" })
Plug("kevinhwang91/rnvimr", { ["on"] = "RnvimrToggle" })
Plug("kyazdani42/nvim-tree.lua", { ["on"] = "NvimTreeToggle" })
Plug("michaelb/sniprun", { ["do"] = "bash install.sh" })
-- }}}

-- Colorschemes {{{
Plug("sainnhe/everforest")
Plug("sainnhe/gruvbox-material")
-- }}}

-- LSP {{{
-- Plug 'github/copilot.vim' -- Node 18 isn't supported yet
Plug("JASONews/glow-hover")
Plug("RRethy/vim-illuminate")
Plug("b0o/schemastore.nvim") -- json support
Plug("folke/lsp-colors.nvim")
Plug("folke/trouble.nvim")
Plug("glepnir/lspsaga.nvim")
Plug("j-hui/fidget.nvim")
Plug("jose-elias-alvarez/null-ls.nvim")
Plug("neovim/nvim-lspconfig")
Plug("ray-x/lsp_signature.nvim")
Plug("simrat39/symbols-outline.nvim")
Plug("williamboman/nvim-lsp-installer")
Plug("zbirenbaum/copilot.lua") -- You need the github/copilot to auth first
-- }}}

-- cmp plugins {{{
Plug("f3fora/cmp-spell")
Plug("hrsh7th/cmp-buffer")
Plug("hrsh7th/cmp-nvim-lsp")
Plug("hrsh7th/cmp-nvim-lua")
Plug("hrsh7th/cmp-path")
Plug("hrsh7th/nvim-cmp")
Plug("onsails/lspkind-nvim")
Plug("rcarriga/cmp-dap")
Plug("saadparwaiz1/cmp_luasnip")
Plug("zbirenbaum/copilot-cmp")
-- }}}

-- snippets {{{
Plug("L3MON4D3/LuaSnip")
Plug("rafamadriz/friendly-snippets")
-- }}}

-- Telescope {{{
Plug("LinArcX/telescope-command-palette.nvim")
Plug("LinArcX/telescope-env.nvim")
Plug("ahmedkhalf/project.nvim")
Plug("fcying/telescope-ctags-outline.nvim")
Plug("jvgrootveld/telescope-zoxide")
Plug("nvim-telescope/telescope-file-browser.nvim")
Plug("nvim-telescope/telescope-hop.nvim")
Plug("nvim-telescope/telescope-symbols.nvim")
Plug("nvim-telescope/telescope.nvim")
Plug("sudormrfbin/cheatsheet.nvim")
Plug("xiyaowong/telescope-emoji.nvim")
Plug("nvim-telescope/telescope-fzf-native.nvim", { ["do"] = "make" })
-- }}}

-- Treesitter {{{
Plug("JoosepAlviste/nvim-ts-context-commentstring")
Plug("m-demare/hlargs.nvim")
Plug("nvim-treesitter/playground")
Plug("p00f/nvim-ts-rainbow")
Plug("romgrk/nvim-treesitter-context")
Plug("windwp/nvim-ts-autotag")
Plug("nvim-treesitter/nvim-treesitter", { ["do"] = ":TSUpdate" })
-- }}}

-- Git {{{
Plug("f-person/git-blame.nvim")
Plug("lewis6991/gitsigns.nvim")
Plug("rhysd/conflict-marker.vim")
Plug("sindrets/diffview.nvim")
-- }}}

-- DAP {{{
Plug("mfussenegger/nvim-dap")
Plug("pocco81/dapinstall.nvim")
Plug("rcarriga/nvim-dap-ui")
Plug("thehamsta/nvim-dap-virtual-text")
-- }}}

-- Markdown & Latex {{{
Plug("cespare/vim-toml", { ["for"] = "toml" })
Plug("ellisonleao/glow.nvim", { branch = "main", ["for"] = "help" })
Plug("elzr/vim-json", { ["for"] = "json" })
Plug("godlygeek/tabular", { ["for"] = "markdown" })
Plug("iamcco/markdown-preview.nvim", { ["do"] = "cd app && yarn install", ["for"] = "markdown" })
Plug("lervag/vimtex", { ["for"] = "latex" }) -- Latex on vim
Plug("plasticboy/vim-markdown", { ["for"] = "markdown" })

---- For Logseq support {{{
-- Mustache and handlebar in vim - Provides automatic clozing of brackes et.al. like in logseq
Plug("mustache/vim-mustache-handlebars", { ["for"] = "markdown" })
-- Plugin to manage Logseq from vim, with fuzzy finding of tags and pages. Journaling and backlinks
Plug("lervag/wiki.vim", { ["for"] = "markdown" })
---- }}}
-- }}}

vim.call("plug#end")
