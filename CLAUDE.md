# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal Neovim configuration (CharlesChiuGit/nvimdots) written in Lua with ~20ms startup time and 100+ plugins. Uses lazy.nvim for plugin management with aggressive lazy loading.

## Commands

```bash
# Format Lua files
stylua lua/

# Run mise task (compile ruler to AGENTS.md)
mise run ruler

```

## Architecture

### Initialization Flow

1. `init.lua` → checks `vim.g.vscode`, loads `home-manager.lua` (NixOS), requires `core`
2. `lua/core/init.lua` → creates directories, sets leader (`,`), configures clipboard/shell, loads options → events → plugins → keymaps
3. `lua/core/pack.lua` → bootstraps lazy.nvim, loads plugin specs from `modules/plugins/*.lua`

### Directory Structure

```
lua/
├── core/                 # Core config (init, options, events, settings, pack)
├── keymap/               # Keymaps organized by category (native vim.keymap.set)
└── modules/
    ├── plugins/          # lazy.nvim plugin specs (completion, editor, tool, ui, lang)
    ├── configs/          # Plugin configurations matching plugins/ structure
    │   └── completion/servers/  # Per-LSP server configurations
    └── utils/            # Utilities (icons, color palette, config extension, keymap helpers)
```

### Plugin Organization

- **Plugin specs**: `lua/modules/plugins/{category}.lua` - lazy.nvim format specs
- **Plugin configs**: `lua/modules/configs/{category}/{plugin}.lua` - configuration functions
- **Keymaps**: `lua/keymap/{category}.lua` - plugin keymaps using native `vim.keymap.set`

### Key Files

- `lua/core/settings.lua` - User-customizable settings (LSPs, formatters, DAPs, treesitter parsers, theme, etc.)
- `lua/core/options.lua` - Neovim editor options
- `lua/core/event.lua` - Autocommands
- `lua/modules/utils/keymap.lua` - Keymap utilities (amend/replace for conditional and user-override keymaps)

### User Customization

Optional `lua/user/` directory for personal overrides:

- `lua/user/settings.lua` - Override settings
- `lua/user/plugins/*.lua` - Additional plugin specs (merged automatically)
- `lua/user/configs/*.lua` - Override plugin configs
- `lua/user/keymap/init.lua` - Override keymaps (returns list of `{ mode, lhs, rhs, opts }` tuples)
- `lua/user/keymap/completion.lua` - Override LSP keymaps (exports `M.lsp(buf)` function)

### Keymaps (lua/keymap/)

Uses native `vim.keymap.set` directly:

```lua
local set = vim.keymap.set
set("n", "<leader>ps", "<Cmd>Lazy sync<CR>", { silent = true, desc = "package: Sync" })
set("n", "K", "<Cmd>Lspsaga hover_doc<CR>", { silent = true, buffer = buf, desc = "lsp: Show doc" })
set({ "n", "v" }, "gra", function()
    require("tiny-code-action").code_action({})
end, { silent = true, buffer = buf, desc = "lsp: Code action" })
```

## Code Style

- Lua formatting: StyLua with tabs, 120 column width (see `stylua.toml`)
- Plugin lazy loading: use `event`, `cmd`, `ft`, or `keys` triggers
- Platform detection via `require("core.global")`: `is_mac`, `is_linux`, `is_windows`, `is_wsl`
- Settings accessed via `require("core.settings").setting_name`

## Adding New Plugins

1. Add spec to `lua/modules/plugins/{category}.lua`
2. Create config at `lua/modules/configs/{category}/{plugin}.lua`
3. Add keymaps to `lua/keymap/{category}.lua`
4. For LSP servers: add to `settings.lsp_deps` and create server config in `configs/completion/servers/`

## Key Design Decisions

- **snacks.nvim** as unified UI layer (notifier, bufdelete, scroll, bigfile, dashboard, indent, terminal, lazygit, quickfile)
- **blink.cmp** as primary completion engine (over nvim-cmp)
- **catppuccin** theme with custom fork for syntax highlighting
- **Conditional search backend**: `settings.search_backend` = "telescope" or "fzf"
- **Copilot disabled by default**: enable via `settings.use_copilot`
- **Transparent background by default**: `settings.transparent_background`
- **VSCode detection**: configuration skipped when `vim.g.vscode` is set
