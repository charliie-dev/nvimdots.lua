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
---@type palette
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

-- Language servers to enable, resolved discovery-first at runtime: binary on $PATH is
-- used as-is; else Mason installs it when it ships a package; else an aggregated warning
-- asks you to provision it. Names whose filetypes lspconfig knows resolve on that
-- filetype's FIRST buffer (a late sweep classifies the rest once per session); names
-- with user overrides, repo modules that override filetypes, or no filetype data
-- resolve on the first file open. See `modules.utils.tools` and
-- `completion/mason-lspconfig.lua`.
-- Full list: https://github.com/neovim/nvim-lspconfig/tree/master/lsp
---@type string[]
settings["lsp_deps"] = {
	"bashls",
	"clangd",
	-- "dartls", -- Dart LSP (ships with the Dart SDK)
	"dockerls",
	"gh_actions_ls",
	-- "gitlab_ci_ls",
	"gopls",
	-- "harper_ls", # too noisy
	"superhtml",
	"jsonls",
	"lua_ls",
	"marksman",
	"neocmake",
	"nil_ls", -- Nix LSP; the Nix-provisioned $PATH binary is preferred
	"nixd", -- Nix LSP (Rust); provisioned from Nix ($PATH)
	"ruff",
	"shuck", -- shell linter/formatter/LSP (Rust); installed via mise by choice ($PATH wins)
	"systemd_lsp",
	"terraformls",
	"tflint",
	"tombi",
	"yamlls",
	"zuban",
}

-- Formatters to resolve when conform.nvim lazy-loads (first BufWritePre /
-- :Format). conform formatter names, resolved discovery-first like lsp_deps.
---@type string[]
settings["formatter_deps"] = {
	"beautysh",
	"clang-format",
	"cmake_format",
	"fixjson",
	"gofumpt",
	"goimports",
	"mdsf",
	"nixfmt", -- Nix formatter; prefer the $PATH binary (Nix)
	"prettier",
	"superhtml",
	"shellharden",
	"statix", -- Nix linter, its `fix` mode doubles as a conform formatter; from Nix ($PATH)
	"stylua",
}

-- Linters to resolve discovery-first (nvim-lint linter names). A name mapped
-- to a filetype resolves on that filetype's FIRST matching event after
-- nvim-lint lazy-loads (the resolve-only FileType autocmd or a lint event) —
-- nothing is installed or warned about before such a buffer opens; unmapped
-- names (typos, manual-only linters) get an immediate deferred pass instead.
---@type string[]
settings["linter_deps"] = {
	"actionlint",
	"deadnix", -- Nix dead-code linter; prefer the $PATH binary (Nix)
	"hadolint",
	"markdownlint-cli2",
	"oxlint",
	-- "rumdl", -- markdownlint Rust rewrite; waiting for rule coverage to mature
	"golangcilint",
	"selene",
	"shellcheck",
	"shuck", -- shell linter for yaml.github `run:` blocks; installed via mise by choice
	"statix", -- Nix linter; prefer the $PATH binary (Nix)
	"systemdlint",
	"zsh", -- `zsh -n` syntax check via the system shell itself
}

-- Deadline (ms) for background Mason work before the aggregated missing-tool warning
-- flushes anyway. Gates each tracked install (its own window) AND the registry refresh
-- wait; late completions still recover. Missing or non-positive values fall back to
-- the resolver's DEFAULT_TOOL_INSTALL_TIMEOUT_MS in `modules/utils/tools.lua`.
---@type number
settings["tool_install_timeout"] = 300000

-- DAP adapters to enable (mason-nvim-dap adapter names), resolved
-- discovery-first when nvim-dap lazy-loads (first :Dap* command or debug keymap).
-- Supported DAPs: https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
---@type string[]
settings["dap_deps"] = {
	"codelldb", -- C-Family
	"delve", -- Go
	"python", -- Python (debugpy)
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
	tmux = true,
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

local merged = require("modules.utils").extend_config(settings, "user.settings")

-- Migration guard: the discovery-first refactor removed this key; a stale
-- user/settings.lua would merge it in and feed nothing — its servers would
-- vanish without a word.
if merged.external_lsp_deps ~= nil then
	-- The removed setting was a MAP of server name -> executable name, but a
	-- stale override can survive in any shape: classify before advising so the
	-- guidance never presents numeric indices as keys, never drops entries a
	-- half-migrated LIST residue still carries, and always names the final
	-- step (deleting the dead key). Neither group suppresses the other.
	local string_keys, list_items = {}, {}
	if type(merged.external_lsp_deps) == "table" then
		for k, v in pairs(merged.external_lsp_deps) do
			if type(k) == "string" then
				string_keys[#string_keys + 1] = k
			elseif type(k) == "number" and type(v) == "string" then
				list_items[#list_items + 1] = v
			end
		end
		table.sort(string_keys)
		table.sort(list_items)
	end
	local guidance
	if #string_keys > 0 and #list_items > 0 then
		guidance = "Move its KEYS ("
			.. table.concat(string_keys, ", ")
			.. ") AND its list entries ("
			.. table.concat(list_items, ", ")
			.. ")\n— all of them server names — into `lsp_deps`, then delete `external_lsp_deps`."
	elseif #string_keys > 0 then
		guidance = "Move its KEYS ("
			.. table.concat(string_keys, ", ")
			.. ") — the server names, not the\n"
			.. "executable values — into `lsp_deps`, then delete `external_lsp_deps`."
	elseif #list_items > 0 then
		guidance = "It now holds a LIST ("
			.. table.concat(list_items, ", ")
			.. ") — those are already the\n"
			.. "server names; move them into `lsp_deps` and delete `external_lsp_deps`."
	else
		guidance = "It is empty or not a map — delete `external_lsp_deps` from user/settings.lua."
	end
	-- (Scheduled: the notifier plugin isn't loaded this early; the default
	-- notify still lands in :messages.)
	vim.schedule(function()
		vim.notify(
			"`external_lsp_deps` was removed: non-Mason servers are now discovered\nfrom $PATH. " .. guidance,
			vim.log.levels.WARN,
			{ title = "core.settings" }
		)
	end)
end

return merged
