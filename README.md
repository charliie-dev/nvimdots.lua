<h1 align="center">
    Neovim Config
</h1>

<p align="center">
    <a href="https://www.lua.org/">
    <img
        alt="Lua"
        src="https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white">
    </a>
    <a href="https://github.com/neovim/neovim">
    <img
        alt="Neovim"
        src="https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white">
    </a>
</p>

<p align="center">
    <a href="https://github.com/charliie-dev/nvimdots.lua/stargazers">
    <img
        alt="Stars"
        src="https://img.shields.io/github/stars/charliie-dev/nvimdots.lua?colorA=363A4F&colorB=B7BDF8&logo=adafruit&logoColor=D9E0EE&style=for-the-badge">
    </a>
    <a href="https://github.com/charliie-dev/nvimdots.lua/issues">
    <img
        alt="Issues"
        src="https://img.shields.io/github/issues-raw/charliie-dev/nvimdots.lua?colorA=363A4f&colorB=F5A97F&logo=github&logoColor=D9E0EE&style=for-the-badge">
    </a>
    <a href="https://github.com/charliie-dev/nvimdots.lua/contributors">
    <img
        alt="Contributors"
        src="https://img.shields.io/github/contributors/charliie-dev/nvimdots.lua?colorA=363A4F&colorB=B5E8E0&logo=git&logoColor=D9E0EE&style=for-the-badge">
    </a>
    <a href="https://github.com/charliie-dev/nvimdots.lua">
    <img
        alt="Code size"
        src="https://img.shields.io/github/languages/code-size/charliie-dev/nvimdots.lua?colorA=363A4F&colorB=DDB6F2&logo=gitlfs&logoColor=D9E0EE&style=for-the-badge">
    </a>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/51954da1-150d-46d2-8552-406a1bd555ff"
  width = "90%"
  />
</p>

<div align="center">
    <h6> R.I.P. Kentaro Miura sensei 🥀 </h6>
</div>

---

## 🎐 Intro

- **⚡BLAZINGLY FAST** startup time in ~40ms. (Tested on M3 Pro MacBooks)
- Well structured in `Lua`.
- Easy to customize.
- Use [lazy.nvim](https://github.com/folke/lazy.nvim) as plugin manager.
- Aligned icons across every plugin!

## 🧱 Structure

`${HOME}/.config/nvim`

```txt
├── Applications/                  macOS application shortcuts
├── after/
│   ├── ftplugin/                  filetype-based rules (c, cpp, dockerfile, go, json,
│   │                              jsonc, make, markdown, nix, python, rust)
│   ├── plugin/
│   │   └── mise.lua               mise integration (after plugin)
│   └── queries/                   custom treesitter queries
│       ├── bash/injections.scm    bash injection queries
│       └── toml/injections.scm    toml injection queries
├── nixos/                         NixOS/home-manager integration
├── scripts/
│   └── update_lockfile.sh         script for updating lazy-lock.json
├── snips/
│   ├── package.json               how LuaSnip reads snippets, vscode-style
│   └── snippets/                  snippet definitions (c, cpp, global, go, lua,
│                                  markdown, python/, rust)
├── spell/                         custom spelling correction
├── flake.nix                      Nix flake for reproducible environment
├── flake.lock                     Nix flake lock file
├── lazy-lock.json                 lazy.nvim plugin lock file
├── mise.toml                      mise task runner config
├── stylua.toml                    stylua settings
├── tombi.toml                     TOML LSP settings
├── init.lua
└── lua/
    ├── core/
    │   ├── event.lua              event-based autocommands
    │   ├── global.lua             global/platform variables
    │   ├── init.lua               bootstrap sequence
    │   ├── options.lua            neovim options
    │   ├── pack.lua               lazy.nvim bootstrap & plugin loader
    │   └── settings.lua           user-customizable settings
    ├── hm-generated.lua           home-manager generated config (NixOS)
    ├── keymap/                    keymaps organized by category
    │   ├── init.lua               package keymaps + requires all categories
    │   ├── viewport.lua           buffer, window, tab keymaps
    │   ├── edit.lua               editing, motion, text objects, session
    │   ├── lsp.lua                LSP, trouble, formatter keymaps
    │   ├── git.lua                gitsigns, diffview, git picker
    │   ├── fuzzy.lua              snacks.nvim picker keymaps
    │   ├── debug.lua              DAP keymaps
    │   ├── terminal.lua           terminal, TUI tools (lazygit, btop, yazi)
    │   ├── tool.lua               overseer, sniprun, sidebar, markview
    │   └── helpers.lua            keymap helper functions
    └── modules/
        ├── plugins/               lazy.nvim plugin specs
        │   ├── completion.lua     LSP, completion, formatting, linting
        │   ├── editor.lua         editing enhancements
        │   ├── lang.lua           language-specific plugins
        │   ├── tool.lua           tools (DAP, search, file explorer, etc.)
        │   └── ui.lua             UI & appearance
        ├── configs/               plugin configurations
        │   ├── completion/        LSP, blink.cmp, conform, nvim-lint configs
        │   │   ├── formatters/    per-formatter configurations
        │   │   └── servers/       per-LSP server configurations
        │   ├── editor/            editor plugin configs
        │   ├── lang/              language plugin configs
        │   ├── tool/              tool configs
        │   │   └── dap/           DAP settings & per-language debug clients
        │   └── ui/                UI plugin configs
        └── utils/                 utility functions
            ├── init.lua           general utilities
            ├── icons.lua          icon definitions
            ├── keymap.lua         keymap utilities (amend/replace)
            └── dap.lua            DAP utilities
```

## ⚙️ Installation

### Native (git clone)

```bash
# Back up existing config (if any)
mv ~/.config/nvim ~/.config/nvim.backup

# Clone the repository
git clone https://github.com/charliie-dev/nvimdots.lua.git ~/.config/nvim

# Launch Neovim — plugins will be installed automatically on first run
nvim
```

For prerequisites and dependencies, see [Wiki: Prerequisite](https://github.com/charliie-dev/nvimdots.lua/wiki/Prerequisite).

### Nix (via home-manager)

This config ships with a `flake.nix` for reproducible setup. Add it to your home-manager configuration:

```nix
{
  inputs.nvimdots.url = "github:charliie-dev/nvimdots.lua";

  # In your home-manager module:
  programs.neovim = {
    enable = true;
    package = inputs.nvimdots.packages.${system}.default;
  };
}
```

See `nixos/` and `flake.nix` for details.

## ⚙️ Configuration & Usage

- [Wiki: Prerequisite](https://github.com/charliie-dev/nvimdots.lua/wiki/Prerequisite) — dependencies and setup
- [Wiki: Usage](https://github.com/charliie-dev/nvimdots.lua/wiki/Usage) — customization guide
- [Wiki: Installed Plugins](https://github.com/charliie-dev/nvimdots.lua/wiki/Plugins) — full plugin list
- [Wiki: FAQ](https://github.com/charliie-dev/nvimdots.lua/wiki/FAQ) — frequently asked questions

## 🪨 Materials

### Docs

- [Lua docs](https://www.lua.org/docs.html)
- [neovim/options](https://neovim.io/doc/user/options.html)
- [neovim/lua-api](https://neovim.io/doc/user/lua.html)
- [neovim Wiki](https://github.com/neovim/neovim/wiki)
- Learn vim/neovim
  - [alpha2phi/Neovim for Beginners, Neovim 101](https://alpha2phi.medium.com/)
  - [Vim Tips Wiki](https://vim.fandom.com/wiki/Vim_Tips_Wiki)
  - [Vim Cheat Sheet](https://vim.rtorr.com/)
  - [Learn Vimscript the Hard Way](https://learnvimscriptthehardway.stevelosh.com/)
  - [Learn Vim the Simple Way](https://www.vimified.com/), a web game to learn vim motions
  - [vim-adventures](https://vim-adventures.com/), another web game to learn vim.
  - [BooleanCube/NeovimKeys](https://github.com/BooleanCube/NeovimKeys), offline vim motion game
  - [ThePrimeagen/vim-be-good](https://github.com/ThePrimeagen/vim-be-good), a plugin by ThePrimeagen
  - [ThePrimeagen/2-simple-steps](https://github.com/ThePrimeagen/2-simple-steps/blob/master/you_think_you_know_vim.ts), another vimtutor by ThePrimeagen
  - [vimcdoc](https://github.com/yianwillis/vimcdoc), a vim doc in Chinese, could be a plugin, a program or a webpage

### YouTube channels

- [ThePrimeagen/Vim As Your Editor](https://www.youtube.com/playlist?list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R), **BLAZINGLY FAST**
  alpha vimfluencer
- [TJ DeVries](https://www.youtube.com/c/TJDeVries/playlists), neovim core team

### Awesomes

- [neovimcraft](https://neovimcraft.com)
- [LibHunt/neovim](https://www.libhunt.com/search?query=neovim)
- [rockerBOO/awesome-neovim](https://github.com/rockerBOO/awesome-neovim)
- [How I Vim](http://howivim.com/)
- [nvim.sh](https://nvim.sh/), neovim plugin search from the terminal
- [Neoland](https://neoland.dev/), a collection of plugins, themes and other resources for Neovim.

### Trendy neovim news

- [This Week In Neovim, hosted by dotfyle.com](https://dotfyle.com/this-week-in-neovim)
- [Reddit/neovim](https://www.reddit.com/r/neovim/)
- [X/neovim](https://x.com/Neovim)
- [Neovim Official News](https://neovim.io/news/)

## 🎉 Acknowledgment

- [ayamir/nvimdot](https://github.com/ayamir/nvimdots)
- [glepnir/nvim](https://github.com/glepnir/nvim)
- [ChristianChiarulli/nvim](https://github.com/ChristianChiarulli/nvim)
- [ray-x/nvim](https://github.com/ray-x/nvim)
- [folke/dot/config/nvim](https://github.com/folke/dot/tree/master/config/nvim)
- [jdhao/nvim-config](https://github.com/jdhao/nvim-config)
