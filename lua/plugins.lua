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
  print("Packer is not installed!")
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "double" })
		end,
	},
	profile = {
		enable = true,
		threshold = 1, -- integer in milliseconds, plugins which load faster than this won't be shown in profile output
	},
	autoremove = true, -- Remove disabled or unused plugins without prompting the user
})

return packer.startup(function(use)
	-- Plugin Manager
	use({ "wbthomason/packer.nvim" })

	-- LSP
  use({ "neovim/nvim-lspconfig" })
  use({ "williamboman/mason.nvim",
    requires = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
  })
  use({ "jose-elias-alvarez/null-ls.nvim" }) -- for formatters and linters
  use({ "ray-x/lsp_signature.nvim" })
  use({ "simrat39/symbols-outline.nvim" })

  use({ "glepnir/lspsaga.nvim" })
  -- use({ "MunifTanjim/prettier.nvim" })
  use({ "JASONews/glow-hover" })
	use({ "RRethy/vim-illuminate" })
	use({ "b0o/SchemaStore.nvim" }) -- json support
	use({ "j-hui/fidget.nvim" })
  use({ "folke/lua-dev.nvim" })
  use({ "lvimuser/lsp-inlayhints.nvim" })
  -- use({ "https://git.sr.ht/~whynothugo/lsp_lines.nvim" })

	-- Completion
  use({ "hrsh7th/nvim-cmp" })
	use({ "hrsh7th/cmp-buffer" })
	use({ "hrsh7th/cmp-nvim-lsp" })
	use({ "hrsh7th/cmp-nvim-lua" })
	use({ "hrsh7th/cmp-path" })
  use({ "andersevenrud/cmp-tmux" })
	use({ "saadparwaiz1/cmp_luasnip" })

  -- use({ "github/copilot.vim" }) -- Node 18 isn't supported yet
	use({ "zbirenbaum/copilot.lua" }) -- You need the github/copilot to auth first
	use({ "zbirenbaum/copilot-cmp",
    after = {
      "copilot.lua",
      "nvim-cmp",
    },
		config = function()
			require("copilot_cmp").setup({
        method = "getCompletionsCycling",
      })
    end,
  })

	-- Snippets
  use({ "michaelb/sniprun", run = "bash ./install.sh" })
	use({ "L3MON4D3/LuaSnip" })
	use({ "rafamadriz/friendly-snippets" })


	-- Syntax/Treesitter
  use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })  -- :TSUpdate will pop error when installing this plugin at the first time.
	use({ "JoosepAlviste/nvim-ts-context-commentstring" })
  use({ "p00f/nvim-ts-rainbow" })
	use({ "windwp/nvim-ts-autotag" })
	use({ "windwp/nvim-autopairs" })
  use({ "nvim-treesitter/nvim-treesitter-textobjects" })
	use({ "m-demare/hlargs.nvim" })
  use({ "abecodes/tabout.nvim" })
  use({ "kylechui/nvim-surround" })


	-- Fuzzy Finder/Telescope
	use({ "LinArcX/telescope-command-palette.nvim" })
	use({ "LinArcX/telescope-env.nvim" })
	use({ "fcying/telescope-ctags-outline.nvim" })
	use({ "jvgrootveld/telescope-zoxide" })
	use({ "nvim-telescope/telescope-symbols.nvim" })
	use({ "nvim-telescope/telescope.nvim", branch = '0.1.x' })
	use({ "sudormrfbin/cheatsheet.nvim" })
	use({ "xiyaowong/telescope-emoji.nvim" })

  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make", cond = vim.fn.executable "make" == 1 })
  use({ "ibhagwan/fzf-lua" })


	-- DAP/Debugging
	use({ "mfussenegger/nvim-dap" })
	-- use({ "Pocco81/dap-buddy.nvim" })  -- plugin being rewritten
	use({ "rcarriga/nvim-dap-ui" })
	use({ "thehamsta/nvim-dap-virtual-text" })
  use({ "nvim-telescope/telescope-dap.nvim" })

  -- python debugger config
  use({ "mfussenegger/nvim-dap-python" })


	-- Git
  use({ "dinhhuy258/git.nvim" })
	use({ "f-person/git-blame.nvim" })
	use({ "lewis6991/gitsigns.nvim" })
  use({ "akinsho/git-conflict.nvim" })
	-- use({ "sindrets/diffview.nvim" })


  -- Utility
	use({ "nvim-lua/plenary.nvim" })
	use({ "nvim-lua/popup.nvim" })
	use({ "moll/vim-bbye" })
	use({ "lewis6991/impatient.nvim" })
	use({ "rcarriga/nvim-notify" })
  use({ "dstein64/vim-startuptime" })
	-- use({ "fgheng/winbar.nvim" })
	use({ "gelguy/wilder.nvim", requires = {{"romgrk/fzy-lua-native"}} })
  use({ "max397574/better-escape.nvim" })
  use({ "akinsho/bufferline.nvim", tag = "v2.*" })
	use({ "aserowy/tmux.nvim" })
  use({ "is0n/fm-nvim" })
  -- use({ "folke/which-key.nvim" })
  -- use({ "linty-org/key-menu.nvim" })


  -- Color
  use({ "NvChad/nvim-colorizer.lua" })
  use({ "nvim-colortils/colortils.nvim" })


	-- Colorschemes
	-- use({ "sainnhe/everforest" })
	use({ "sainnhe/gruvbox-material" })
	-- use({ "rebelot/kanagawa.nvim" })
	-- use({ "decaycs/decay.nvim", as = "decay" })


  -- Icon
	use({ "kyazdani42/nvim-web-devicons" })


  -- Statusline
	use({ "nvim-lualine/lualine.nvim" })


  -- Startup
	use({ "goolord/alpha-nvim" })


  -- Indent
	use({ "lukas-reineke/indent-blankline.nvim" })


  -- File Explorer
	use({ "kyazdani42/nvim-tree.lua" })


  -- Comment
	use({ "numToStr/Comment.nvim" })
	-- use({ "B4mbus/todo-comments.nvim" })
  use({ "folke/todo-comments.nvim" })


  -- Terminal
	use({ "akinsho/toggleterm.nvim" })


  -- Project
	use({ "ahmedkhalf/project.nvim" })
	use({ "nvim-pack/nvim-spectre" })


  -- Editing Support
	use({ "Pocco81/AutoSave.nvim" })
	use({ "karb94/neoscroll.nvim" })
	use({ "nacro90/numb.nvim" })
  use({ "ethanholz/nvim-lastplace" })
	use({ "gbprod/yanky.nvim" })
  use({ "ojroques/nvim-osc52" })
  use({ "kevinhwang91/nvim-hlslens" })
  use({ "smjonas/inc-rename.nvim" })

  -- Motion
	use({ "phaazon/hop.nvim" })
	use({ "ThePrimeagen/harpoon" })
  use({ "nvim-telescope/telescope-hop.nvim" })


  -- Python
  use({ "IllustratedMan-code/telescope-conda.nvim" })


	-- Markdown & Latex
	use({
		"iamcco/markdown-preview.nvim",
    opt = true,
    ft = "markdown",
		run = function()
			vim.fn["mkdp#util#install"]()
		end,
	})
	use({
    "lervag/vimtex",
    -- opt = true,
    -- ft = "tex",
  }) -- Latex on vim
	use({
    "plasticboy/vim-markdown",
    -- opt = true,
    -- ft = "markdown",
  })
  -- use({
    -- "jakewvincent/mkdnflow.nvim",
    -- rocks = "luautf8",
    -- opt = true,
    -- ft = "markdown",
    -- config = require("config.mkdnflow")
  -- }) -- Ensures optional luautf8 dependency is installed

	if PACKER_BOOTSTRAP then
		packer.sync()
	end
end)
