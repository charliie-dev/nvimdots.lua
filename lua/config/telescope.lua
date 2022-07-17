local status, telescope = pcall(require, "telescope")
if not status then
  return
end

local project_status, project_nvim = pcall(require, "project_nvim")
if not project_status then
  return
end

local icons = require("icons")

local actions = require("telescope.actions")
local builtin = require("telescope.builtin")
-- local trouble = require("trouble.providers.telescope") -- LSP trouble diagnostics

telescope.setup({
  defaults = {
    prompt_prefix = icons.ui.Telescope .. " ",
    selection_caret = " ",
    path_display = { "smart" },
    file_ignore_patterns = { ".git/", "node_modules/", "target/", "docs/", ".settings/" },
    mappings = {
      n = {
        ["<esc>"] = actions.close,
        ["<CR>"] = actions.select_default,

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,

        ["j"] = actions.move_selection_next,
        ["k"] = actions.move_selection_previous,
        ["<Down>"] = actions.move_selection_next,
        ["<Up>"] = actions.move_selection_previous,

        ["gg"] = actions.move_to_top,
        ["G"] = actions.move_to_bottom,
      },
      i = {
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,

        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,

        ["<C-c>"] = actions.close,

        ["<Down>"] = actions.move_selection_next,
        ["<Up>"] = actions.move_selection_previous,

        ["<CR>"] = actions.select_default,

        ["<PageUp>"] = actions.results_scrolling_up,
        ["<PageDown>"] = actions.results_scrolling_down,

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,

        ["<C-h>"] = telescope.extensions.hop.hop, -- hop.hop_toggle_selection
      },
    },
  },
  extensions = {
    conda = {
      home = "$HOME/anaconda3"
    },
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
    -- file_browser = {
    --   -- theme = "ivy",
    --   -- disables netrw and use telescope-file-browser in its place
    --   hijack_netrw = false,
    --   mappings = {
    --     ["i"] = {
    --       -- your custom insert mode mappings
    --     },
    --     ["n"] = {
    --       -- your custom normal mode mappings
    --     },
    --   },
    -- },
    ctags_outline = {
      --ctags option
      ctags = { "ctags" },
      --ctags filetype option
      -- ft_opt = {
      --   vim = '--vim-kinds=fk',
      --   lua = '--lua-kinds=fk',
      -- },
    },
    emoji = {
      action = function(emoji)
        -- argument emoji is a table.
        -- {name="", value="", cagegory="", description=""}

        vim.fn.setreg("*", emoji.value)
        print([[Press p or "*p to paste this emoji]] .. emoji.value)

        -- insert emoji when picked
        -- vim.api.nvim_put({ emoji.value }, 'c', false, true)
      end,
    },
    hop = {
      -- Highlight groups to link to signs and lines; the below configuration refers to demo
      -- sign_hl typically only defines foreground to possibly be combined with line_hl
      sign_hl = { "WarningMsg", "Title" },
      -- optional, typically a table of two highlight groups that are alternated between
      line_hl = { "CursorLine", "Normal" },
      -- options specific to `hop_loop`
      -- true temporarily disables Telescope selection highlighting
      clear_selection_hl = false,
      -- highlight hopped to entry with telescope selection highlight
      -- note: mutually exclusive with `clear_selection_hl`
      trace_entry = true,
      -- jump to entry where hoop loop was started from
      reset_selection = true,
    },
    command_palette = {
      {
        "File",
        { "entire selection (C-a)", ':call feedkeys("GVgg")' },
        { "save current file (C-s)", ":w" },
        { "save all files (C-A-s)", ":wa" },
        { "quit (C-q)", ":qa" },
        { "file browser (C-i)", ":lua require'telescope'.extensions.file_browser.file_browser()", 1 },
        { "search word (A-w)", ":lua require('telescope.builtin').live_grep()", 1 },
        { "git files (A-f)", ":lua require('telescope.builtin').git_files()", 1 },
        { "files (C-f)", ":lua require('telescope.builtin').find_files()", 1 },
      },
      {
        "Help",
        { "tips", ":help tips" },
        { "cheatsheet", ":help index" },
        { "tutorial", ":help tutor" },
        { "summary", ":help summary" },
        { "quick reference", ":help quickref" },
        { "search help(F1)", ":lua require('telescope.builtin').help_tags()", 1 },
      },
      {
        "Vim",
        { "reload vimrc", ":source $MYVIMRC" },
        { "check health", ":checkhealth" },
        { "jumps (Alt-j)", ":lua require('telescope.builtin').jumplist()" },
        { "commands", ":lua require('telescope.builtin').commands()" },
        { "command history", ":lua require('telescope.builtin').command_history()" },
        { "registers (A-e)", ":lua require('telescope.builtin').registers()" },
        { "colorshceme", ":lua require('telescope.builtin').colorscheme()", 1 },
        { "vim options", ":lua require('telescope.builtin').vim_options()" },
        { "keymaps", ":lua require('telescope.builtin').keymaps()" },
        { "buffers", ":Telescope buffers" },
        { "search history (C-h)", ":lua require('telescope.builtin').search_history()" },
        { "paste mode", ":set paste!" },
        { "cursor line", ":set cursorline!" },
        { "cursor column", ":set cursorcolumn!" },
        { "spell checker", ":set spell!" },
        { "relative number", ":set relativenumber!" },
        { "search highlighting (F12)", ":set hlsearch!" },
      },
    },
  },
})

-- zoxide config {{{
local z_utils = require("telescope._extensions.zoxide.utils")

require("telescope._extensions.zoxide.config").setup({
  prompt_title = "[ Zoxide List ]",

  -- Zoxide list command with score
  list_command = "zoxide query -ls",
  mappings = {
    default = {
      action = function(selection)
        vim.cmd("cd " .. selection.path)
      end,
      after_action = function(selection)
        print("Directory changed to " .. selection.path)
      end,
    },
    ["<C-s>"] = { action = z_utils.create_basic_command("split") },
    ["<C-v>"] = { action = z_utils.create_basic_command("vsplit") },
    ["<C-e>"] = { action = z_utils.create_basic_command("edit") },
    ["<C-b>"] = {
      keepinsert = true,
      action = function(selection)
        builtin.file_browser({ cwd = selection.path })
      end,
    },
    ["<C-f>"] = {
      keepinsert = true,
      action = function(selection)
        builtin.find_files({ cwd = selection.path })
      end,
    },
  },
})
-- }}}

-- emogi config {{{
-- :Telescope emoji

-- }}}

-- symbols config {{{
-- :Telescope symbols
-- :lua require'telescope.builtin'.symbols{ sources = {'emoji'} }
-- :lua require'telescope.builtin'.symbols{ sources = {'emoji', 'kaomoji', 'gitmoji'} }
-- }}}

-- Project config {{{
project_nvim.setup({
  -- Manual mode doesn't automatically change your root directory, so you have
  -- the option to manually do so using `:ProjectRoot` command.
  manual_mode = false,

  -- Methods of detecting the root directory. **"lsp"** uses the native neovim
  -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
  -- order matters: if one is not detected, the other is used as fallback. You
  -- can also delete or rearangne the detection methods.
  detection_methods = { "lsp", "pattern" },

  -- All the patterns used to detect root dir, when **"pattern"** is in
  -- detection_methods
  patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", --[[ "package.json" ]] },

  -- Table of lsp clients to ignore by name
  -- eg: { "efm", ... }
  ignore_lsp = { "null-ls" },

  -- Don't calculate root dir on specific directories
  -- Ex: { "~/.cargo/*", ... }
  exclude_dirs = { "~/.config/*" },

  -- Show hidden files in telescope
  show_hidden = true,

  -- When set to false, you will get a message when project.nvim changes your
  -- directory.
  silent_chdir = false,

  -- Path where project.nvim will store the project history for use in
  -- telescope
  datapath = vim.fn.stdpath("data"),
})
-- }}}

-- {{{
local yanky_mapping = require("yanky.telescope.mapping")

require("yanky").setup({
  picker = {
    telescope = {
      yanky_mappings = {
        default = yanky_mapping.put("p"),
        i = {
          ["<c-p>"] = yanky_mapping.put("p"),
          ["<c-k>"] = yanky_mapping.put("P"),
          ["<c-x>"] = yanky_mapping.delete(),
        },
        n = {
          p = yanky_mapping.put("p"),
          P = yanky_mapping.put("P"),
          d = yanky_mapping.delete(),
        },
      }
    }
  }
})

-- }}}

-- plugins should load after setup function
telescope.load_extension("zoxide")
telescope.load_extension("command_palette")
telescope.load_extension("ctags_outline")
telescope.load_extension("projects")
telescope.load_extension("env")
telescope.load_extension("fzf")
telescope.load_extension("hop")
telescope.load_extension("emoji")
-- telescope.load_extension("file_browser")
telescope.load_extension("harpoon")
telescope.load_extension("notify")
telescope.load_extension("yank_history")
