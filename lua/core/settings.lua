local settings = {}

-- Set to false if you want to use HTTPS to update plugins and Treesitter parsers.
---@type boolean
settings["use_ssh"] = false

-- Set to false if you don't want to format on save.
---@type boolean
settings["format_on_save"] = true

-- Format timeout in milliseconds.
---@type number
settings["format_timeout"] = 3000

-- Set to false to disable format notification.
---@type boolean
settings["format_notify"] = true

-- Set to true if you want to format ONLY the *changed lines* (git hunks via gitsigns).
-- Falls back to formatting the whole buffer if no hunks are found.
---@type boolean
settings["format_modifications_only"] = false

-- Filetypes in this list will skip LSP formatting if the value is true.
---@type table<string, boolean>
settings["formatter_block_list"] = {
	-- Example
	lua = false,
}

-- Directories where formatting on save is disabled.
-- NOTE: Strings may contain regular expressions (vim regex). |regexp|
-- NOTE: Directories are automatically normalized using |vim.fs.normalize()|.
---@type string[]
settings["format_disabled_dirs"] = {
	-- Example
	"~/format_disabled_dir",
}

-- Set to false to disable virtual lines for diagnostics.
-- You can still view diagnostics using trouble.nvim (`<leader>ld`).
---@type boolean
settings["diagnostics_virtual_lines"] = true

-- Set the minimum severity level of diagnostics to display.
-- Priority: `Error` > `Warning` > `Information` > `Hint`.
-- For example, if set to `Warning`, only warnings and errors will be shown.
-- NOTE: This only works when `diagnostics_virtual_lines` is true.
---@type "ERROR"|"WARN"|"INFO"|"HINT"
settings["diagnostics_level"] = "HINT"

-- List plugins to disable here (e.g., "Some-User/A-Repo").
---@type string[]
settings["disabled_plugins"] = {}

-- Customize the global color palette here.
-- These settings will override the defaults during initialization.
-- Parameters will auto-complete as you type.
-- Example: { sky = "#04A5E5" }
---@type palette[]
settings["palette_overwrite"] = {}

-- Set the colorscheme here.
-- Valid options: `catppuccin`, `catppuccin-latte`, `catppuccin-mocha`, `catppuccin-frappe`, `catppuccin-macchiato`.
---@type string
settings["colorscheme"] = "catppuccin"

-- Set to true if your terminal supports a transparent background.
---@type boolean
settings["transparent_background"] = true

-- Set the background mode here.
-- Useful for themes with both light and dark variants.
-- Valid values: `dark`, `light`.
---@type "dark"|"light"
settings["background"] = "dark"

-- Set the command for opening external URLs.
-- This is ignored on Windows and macOS, which use built-in handlers.
---@type string
settings["external_browser"] = "chrome-cli open"

-- Set to false to disable LSP inlay hints.
---@type boolean
settings["lsp_inlayhints"] = false

-- LSPs installed outside Mason (e.g. via system package manager).
-- These will be configured but not installed by Mason.
-- Key: lspconfig server name, Value: executable name to check availability.
---@type table<string, string>
settings["external_lsp_deps"] = {
	nixd = "nixd",
	nil_ls = "nil",
	-- dartls = "dart",
}

-- LSPs to install during bootstrap.
-- Full list: https://github.com/neovim/nvim-lspconfig/tree/master/lsp
---@type string[]
settings["lsp_deps"] = {
	"bashls",
	"clangd",
	"dockerls",
	"gh_actions_ls",
	"gitlab_ci_ls",
	"gopls",
	-- "harper_ls", # too noisy
	"superhtml",
	"jsonls",
	"lua_ls",
	"marksman",
	"neocmake",
	"ruff",
	"systemd_lsp",
	"terraformls",
	"tflint",
	"tombi",
	"yamlls",
	"zuban",
}

-- Formatters to install during bootstrap (Mason package names).
-- These are managed by Mason and used by conform.nvim.
---@type string[]
settings["formatter_deps"] = {
	"beautysh",
	"clang-format",
	"cmakelang",
	"fixjson",
	"gofumpt",
	"goimports",
	"mdsf",
	"prettier",
	"superhtml",
	"shellharden",
	"stylua",
}

-- Linters to install during bootstrap (Mason package names).
-- These are managed by Mason and used by nvim-lint.
---@type string[]
settings["linter_deps"] = {
	"actionlint",
	"hadolint",
	"markdownlint-cli2",
	"oxlint",
	-- "rumdl", -- markdownlint Rust rewrite; waiting for rule coverage to mature
	"golangci-lint",
	"selene",
	"shellcheck",
	"systemdlint",
}

-- Debug Adapter Protocol (DAP) clients to install and configure during bootstrap.
-- Supported DAPs: https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
---@type string[]
settings["dap_deps"] = {
	"codelldb", -- C-Family
	"delve", -- Go
	"python", -- Python (debugpy)
}

-- Treesitter parsers to install during bootstrap.
-- Full list: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
---@type string[]
settings["treesitter_deps"] = {
	"awk",
	"bash",
	"c",
	"cmake",
	"cpp",
	"css",
	"gh_actions_expressions",
	"git_config",
	"go",
	"gomod",
	"gosum",
	"gotmpl",
	"gitignore",
	"hcl",
	"html",
	"javascript",
	"json",
	"kdl",
	"lua",
	"make",
	"markdown",
	"markdown_inline",
	"nix",
	"python",
	"regex",
	"rust",
	"ssh_config",
	"terraform",
	"tmux",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

-- Set the dashboard startup image here.
-- Generate ASCII art with: https://github.com/TheZoraiz/ascii-image-converter
-- More info: https://github.com/ayamir/nvimdots/wiki/Issues#change-dashboard-startup-image
---@type string[]
settings["dashboard_image"] = {
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⢶⡶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⠟⠁⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣴⣶⣿⣿⣿⣿⣿⣷⣾⣶⣶⢂⣴⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢋⡴⠋⠁⠀⠀⠀⢀⣴⣶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣋⠒⠁⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣷⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣡⡾⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢟⣱⡦⠋⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀ ⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⢵⠿⠋⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠈⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠋⠀⠀⠀⠀⠀⠀⠀⢀⢴⣿⠟⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⡀⠀⠀⠀⠀⠀⠀⣠⡶⠶⣿⡍⣆⠗⢨⠄⠉⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣯⠀⠀⠀⠀⣀⣌⠻⡷⠮⠻⡇⣏⣰⡥⠄⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀]],
	[[⠀⠀⠀⠐⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⡟⠉⠁⣀⠀⢀⣼⣿⠟⠁⠀⢃⠀⢡⠞⠛⣠⣶⣠⡀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀]],
	[[⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⣰⣿⣿⢻⣿⠏⡴⠀⣰⠏⠀⠀⠚⠙⠛⣿⡿⢿⡀⠂⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀]],
	[[⠀⠀⠀⣿⣿⣏⢟⡩⢹⣿⣟⡿⣋⣴⣷⠀⠀⠸⣻⠏⠐⡟⢘⣁⡼⠃⠀⠀⠀⠀⠤⠗⠛⠓⠒⠛⠂⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡗⠀⠀⠀]],
	[[⠀⠀⠀⣿⣿⣿⣷⢬⣿⠇⣩⣾⣿⣿⣿⡖⠀⠀⠁⠀⠀⣿⡵⠛⠀⣠⣄⣀⡀⠀⠀⠀⢘⡽⠁⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣗⠀⠀⠀]],
	[[⠀⠀⠀⣿⣿⣿⣷⡛⠁⣰⣿⣿⣿⣿⣿⣿⡃⠀⠀⠀⢀⣫⣥⠀⣴⣿⣿⣿⠿⠿⠟⠀⢸⡃⠀⡅⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀]],
	[[⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣤⣄⣤⣿⡿⠟⠘⠛⠉⠉⠀⢀⠀⡀⡆⢹⣽⡈⠀⣠⣾⠇⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀]],
	[[⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣶⠤⠀⠀⣀⠾⠼⠲⠃⠉⢏⠃⠀⠀⣿⣿⡃⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⡏⡅⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⠃⠀⠀⠹⠉⠁⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣄⡀⠀⠀⠀⣀⣤⣶⣾⣧⣀⡿⠀⠀⠀⠀⠀⣆⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⡿⢻⣿⡟⠀⠀⠀ ⠀]],
	[[⠀⠀⠀ ⠀⠀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⠃⠀⠀⠰⠂⠀⠆⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⠻⣿⣷⣿⡟⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠘⠟⠀⠀⠠⠠⠀⠀⠀⠀⠂⠀⠀⠀⠀⠀⢻⣭⣿⣿⣧⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢻⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⡿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠿⣿⣿⣿⣟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⠿⢿⠿⠷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
}

return require("modules.utils").extend_config(settings, "user.settings")
