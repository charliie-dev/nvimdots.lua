local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Autocmd that recompiles
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status, packer = pcall(require, "packer")
if not status then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
	profile = {
		enable = true,
		threshold = 1, -- integer in milliseconds, plugins which load faster than this won't be shown in profile output
	},
	autoremove = true, -- Remove disabled or unused plugins without prompting the user
})

return packer.startup(function(use)
	-- Packer can manage itself
	use({ "wbthomason/packer.nvim" })

	-- Fundamentals {{{
	-- use {"junegunn/vim-plug"}

	use({ "Pocco81/AutoSave.nvim" })
	-- use({ "SmiteshP/nvim-navic" })
	use({ "ThePrimeagen/harpoon" })
	use({ "akinsho/bufferline.nvim" })
	use({ "akinsho/toggleterm.nvim" })
	use({ "aserowy/tmux.nvim" })
	use({ "dstein64/vim-startuptime" })
	use({ "farmergreg/vim-lastplace" })
	-- use({ "filipdutescu/renamer.nvim" })
	use({ "folke/todo-comments.nvim" })
	use({ "gelguy/wilder.nvim" })
	use({ "goolord/alpha-nvim" })
	use({ "ibhagwan/fzf-lua" })
	use({ "karb94/neoscroll.nvim" })
	use({ "kyazdani42/nvim-tree.lua" })
	use({ "kyazdani42/nvim-web-devicons" })
	use({ "lewis6991/impatient.nvim" })
	use({ "lukas-reineke/indent-blankline.nvim" })
	use({ "michaelb/sniprun", run = "bash ./install.sh" })
	use({ "moll/vim-bbye" })
	use({ "nacro90/numb.nvim" })
	use({ "norcalli/nvim-colorizer.lua" })
	use({ "numToStr/Comment.nvim" })
	use({ "nvim-lua/plenary.nvim" })
	use({ "nvim-lua/popup.nvim" })
	use({ "nvim-lualine/lualine.nvim" })
	use({ "nvim-pack/nvim-spectre" })
	use({ "phaazon/hop.nvim" })
	use({ "rcarriga/nvim-notify" })
	use({ "romgrk/fzy-lua-native" })
	-- use({ "ur4ltz/surround.nvim" })
	use({ "machakann/vim-sandwich" })
	use({ "windwp/nvim-autopairs" })
	use({ "fgheng/winbar.nvim" })
	use({ "SmiteshP/nvim-gps" })
	-- use({ "ojroques/vim-oscyank" })
	use({ "jdhao/better-escape.vim" })
	use({ "gbprod/yanky.nvim" })
	-- }}}

	-- Colorschemes {{{
	-- use({ "sainnhe/everforest" })
	use({ "sainnhe/gruvbox-material" })
	use({ "rebelot/kanagawa.nvim" })
	use({ "decaycs/decay.nvim", as = "decay" })
	-- }}}

	-- LSP {{{
	-- use({ "github/copilot.vim" }) -- Node 18 isn't supported yet
	use({ "JASONews/glow-hover" })
	use({ "RRethy/vim-illuminate" })
	use({ "b0o/schemastore.nvim" }) -- json support
	use({ "folke/lsp-colors.nvim" })
	use({ "j-hui/fidget.nvim" })
	use({ "jose-elias-alvarez/null-ls.nvim" })
	use({ "neovim/nvim-lspconfig" })
	use({ "ray-x/lsp_signature.nvim" })
	use({ "simrat39/symbols-outline.nvim" })
	use({ "williamboman/nvim-lsp-installer" })
  use({ "williamboman/mason.nvim" })
  use({ "williamboman/mason-lspconfig.nvim" })
	use({ "zbirenbaum/copilot.lua" }) -- You need the github/copilot to auth first
	-- }}}

	-- cmp plugins {{{
	-- use({ "f3fora/cmp-spell" })
	-- use({ "hrsh7th/cmp-cmdline" })
	use({ "hrsh7th/cmp-buffer" })
	use({ "hrsh7th/cmp-nvim-lsp" })
	use({ "hrsh7th/cmp-nvim-lua" })
	use({ "hrsh7th/cmp-path" })
	use({ "hrsh7th/nvim-cmp" })
	use({ "onsails/lspkind-nvim" })
	-- use({ "rcarriga/cmp-dap" })
	use({ "saadparwaiz1/cmp_luasnip" })
	use({ "zbirenbaum/copilot-cmp", module = "copilot_cmp" })
	-- }}}

	-- snippets {{{
	use({ "L3MON4D3/LuaSnip" })
	use({ "rafamadriz/friendly-snippets" })
	-- }}}

	-- Telescope {{{
	use({ "LinArcX/telescope-command-palette.nvim" })
	use({ "LinArcX/telescope-env.nvim" })
	use({ "ahmedkhalf/project.nvim" })
	use({ "fcying/telescope-ctags-outline.nvim" })
	use({ "jvgrootveld/telescope-zoxide" })
	-- use({ "nvim-telescope/telescope-file-browser.nvim" })
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
	use({ "nvim-telescope/telescope-hop.nvim" })
	use({ "nvim-telescope/telescope-symbols.nvim" })
	use({ "nvim-telescope/telescope.nvim" })
	use({ "sudormrfbin/cheatsheet.nvim" })
	use({ "xiyaowong/telescope-emoji.nvim" })
	use({ "IllustratedMan-code/telescope-conda.nvim" })
	-- }}}

	-- Treesitter {{{
	use({ "JoosepAlviste/nvim-ts-context-commentstring" })
	use({ "m-demare/hlargs.nvim" })
	use({ "nvim-treesitter/nvim-treesitter" })
	use({ "p00f/nvim-ts-rainbow" })
	use({ "romgrk/nvim-treesitter-context" })
	use({ "windwp/nvim-ts-autotag" })
	-- }}}

	-- Git {{{
	use({ "f-person/git-blame.nvim" })
	use({ "lewis6991/gitsigns.nvim" })
	use({ "rhysd/conflict-marker.vim" })
	-- use({ "sindrets/diffview.nvim" })
	-- }}}

	-- DAP {{{
	use({ "mfussenegger/nvim-dap" })
	use({ "Pocco81/DAPInstall.nvim" })
	use({ "rcarriga/nvim-dap-ui" })
	-- use({ "thehamsta/nvim-dap-virtual-text" })
	-- }}}

	-- Markdown & Latex {{{
	use({ "cespare/vim-toml" })
	use({ "elzr/vim-json" })
	use({ "godlygeek/tabular" })
	use({
		"iamcco/markdown-preview.nvim",
		run = function()
			vim.fn["mkdp#util#install"]()
		end,
	})
	use({ "lervag/vimtex" }) -- Latex on vim
	use({ "plasticboy/vim-markdown" })

	---- For Logseq support {{{
	-- Mustache and handlebar in vim - Provides automatic clozing of brackes et.al. like in logseq
	use({ "mustache/vim-mustache-handlebars" })
	---- }}}
	-- }}}

	if PACKER_BOOTSTRAP then
		packer.sync()
	end
end)
