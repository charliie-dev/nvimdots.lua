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

-- LSP server names expected by the config and Muster.
-- Install packages manually with :MasonInstall or another package manager.
-- Full list: https://github.com/neovim/nvim-lspconfig/tree/master/lsp
---@type (string|{ name: string, command: string })[]
settings["lsp_deps"] = {
	"bashls",
	"clangd",
	-- "dart",
	"dockerls",
	"gh_actions_ls",
	"gopls",
	-- "harper_ls", -- too noisy
	{ name = "jsonls", command = "vscode-json-language-server" },
	"lua_ls",
	"marksman",
	"neocmake",
	"nil_ls",
	"nixd",
	"ruff",
	"shuck", -- shell linter/formatter/LSP (Rust)
	"superhtml",
	"systemd_lsp",
	"terraformls",
	"tflint",
	"tombi",
	{ name = "yamlls", command = "yaml-language-server" },
	"zuban",
}

-- Conform formatter names expected by the config and Muster.
-- Install their executables manually with :MasonInstall or another package manager.
---@type string[]
settings["formatter_deps"] = {
	"beautysh",
	"clang-format",
	"cmake_format",
	"fixjson",
	"gofumpt",
	"goimports",
	"mdsf",
	"nixfmt",
	"prettier",
	"shellharden",
	"statix",
	"stylua",
	"superhtml",
}

-- nvim-lint names expected by the config and Muster.
-- Install their executables manually with :MasonInstall or another package manager.
---@type (string|{ name: string, command: string })[]
settings["linter_deps"] = {
	"actionlint",
	"deadnix",
	"golangcilint",
	"hadolint",
	"markdownlint-cli2",
	{ name = "oxlint", command = "oxlint" },
	-- "rumdl", -- markdownlint Rust rewrite; waiting for rule coverage to mature
	"selene",
	"shellcheck",
	"shuck",
	"statix",
	"systemdlint",
	"zsh",
}

-- DAP adapter names Muster can safely verify. Go and Python are plugin-owned
-- callback factories, so they remain configured but are omitted from Muster to
-- avoid unverifiable startup notifications.
---@type string[]
settings["dap_deps"] = {
	"codelldb", -- C-Family
}

-- Treesitter parsers to install during bootstrap.
-- Full list: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
---@type table<string, boolean>
settings["treesitter_deps"] = {
	awk = true,
	bash = true,
	c = true,
	cmake = true,
	cpp = true,
	css = true,
	gh_actions_expressions = true,
	git_config = true,
	gitignore = true,
	go = true,
	gomod = true,
	gosum = true,
	gotmpl = true,
	hcl = true,
	html = true,
	javascript = true,
	json = true,
	kdl = true,
	lua = true,
	make = true,
	markdown = true,
	markdown_inline = true,
	nix = true,
	python = true,
	regex = true,
	rust = true,
	ssh_config = true,
	terraform = true,
	toml = true,
	tsx = true,
	typescript = true,
	vim = true,
	vimdoc = true,
	yaml = true,
	scss = true,
	svelte = true,
	typst = true,
	vue = true,
}

-- Generated with https://github.com/TheZoraiz/ascii-image-converter
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
