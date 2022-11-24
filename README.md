<h1 align="center">
    Neovim Config
</h1>

<p align="center">
    <a href="https://github.com/CharlesChiuGit/nvimdots/stargazers">
    <img
        alt="GitHub Repo stars"
        src="https://img.shields.io/github/stars/CharlesChiuGit/nvimdots?color=957FB8&logo=starship&style=for-the-badge">
    </a>
    <a href="https://github.com/CharlesChiuGit/nvimdots/issues">
    <img
        alt="GitHub issues"
        src="https://img.shields.io/github/issues-raw/CharlesChiuGit/nvimdots?color=DCA561&logo=gitbook&logoColor=d9e0ee&style=for-the-badge">
    </a>
    <a href="https://github.com/CharlesChiuGit/nvimdots/contributors">
    <img
        alt="GitHub contributors"
        src="https://img.shields.io/github/contributors/CharlesChiuGit/nvimdots?color=%2398BB6C&logo=opensourceinitiative&logoColor=d9e0ee&style=for-the-badge">
    </a>
    <img
        alt="GitHub code size in bytes"
        src="https://img.shields.io/github/languages/code-size/CharlesChiuGit/nvimdots?color=%237E9CD8&logo=gitlfs&logoColor=d9e0ee&style=for-the-badge">
</p>

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
</a>

<p align="center">
  <img src="https://raw.githubusercontent.com/CharlesChiuGit/nvimdots/main/.github/images/alpha-full.png"
  width = "90%"
  />
</p>

<!-- <blockquote align="center"> -->
<!--     R.I.P. Kentaro Miura sensei 🥀 -->
<!-- </blockquote> -->

<div align="center">
    <h6> R.I.P. Kentaro Miura sensei 🥀 </h6>
</div>

---

# 🎐 Intro

- **⚡BLAZINGLY FAST** startup time in ~20ms, with over 100 plugins. (Tested on Micron Crucial MX500)
- Well structured in `Lua`.
- Easy to customize.
- Automized [installation scripts](https://github.com/CharlesChiuGit/dotfiles/blob/main/install_scripts/nvim_setup_linux.sh)(in my other dotfile repo), written in `bash`.
- 100% lazy-loading. Ok, I lied. You can't really lazy-load the theme, UI will look weird.
- Use [delaytrain.nvim](https://github.com/ja-ford/delaytrain.nvim) to train yourself into a better vimer, disable it if you want.
- Aligned icons across every plugin!

# 🧱 Structure

`${HOME}/.config/nvim`

```txt
├── after/
│   └── ftplugin/                  filetype-based rules
├── fonts/                         nerdfonts
├── ftdetect/                      filetype detection
├── scripts
│   ├── nvim_up.sh                 script for upgrade to neovim nightly
│   ├── setup_config.sh            script for installing dependencies for plugins
│   └── update_config.sh           script for fetch new commits of this repo
├── init.lua
├── lua/
│   ├── core/
│   │   ├── event.lua              event-based autocommands
│   │   ├── global.lua             global variables
│   │   ├── init.lua
│   │   ├── mapping.lua            basic keymaps
│   │   ├── options.lua            neovim options
│   │   └── pack.lua               custom packer wrapper
│   ├── keymap/                    plugin-related keymaps
│   ├── modules/                   plugin-configs
│   │   ├── completion/            nvim-cmp + LSP
│   │   │   ├── plugins.lua
│   │   │   └── server-settings/   settings for each LSP
│   │   ├── editor/
│   │   │   └── plugins.lua
│   │   ├── lang
│   │   │   └── plugins.lua
│   │   ├── tools/
│   │   │   ├── dap/               DAP settings for each language
│   │   │   └── plugins.lua
│   │   └── ui/
│   │       └── plugins.lua
│   └── utils                      utility functions
│       └── init.lua
├── snippets/
│   └── package.json               how `LuaSnip` reads snippets, vscode-style
├── spell/                         custom spelling correction
└── stylua.toml                    stylua settings
```

NOTE: You can rename/create folders inside `modules`, but **ALWAYS** remember to add a `plugins.lua` in it to register your plugins.

# 🕵️ Details

<h3 align="center">
    🎩 Suit up
</h3>

Follow [Prerequisite](https://github.com/CharlesChiuGit/nvimdots/wiki/Prerequisite) to install required packages and get yourself a cup of coffee ☕.

<h3 align="center">
    🧑‍🍳 Cook it
</h3>

Follow [Usage](https://github.com/CharlesChiuGit/nvimdots/wiki/Usage) to spice it into your own flavor. (WIP)

<h3 align="center">
    🛠️ Toolbox
</h3>

Lists of [Installed Plugins](https://github.com/CharlesChiuGit/nvimdots/wiki/Plugins). (WIP)

<h3 align="center">
    🗝️🗺️
</h3>

Brief intro of [Core Keymaps](https://github.com/CharlesChiuGit/nvimdots/wiki/Keymaps).

<h3 align="center">
    🤔 FAQ
</h3>

Check [FAQ](https://github.com/CharlesChiuGit/nvimdots/wiki/FAQ) for more FAQ. (WIP)

<h3 align="center">
    ⏱️ Startup Time
</h3>

<p align="center">
  <img src="https://raw.githubusercontent.com/CharlesChiuGit/nvimdots/main/.github/images/startuptime.png"
  width = "70%"
  />
</p>

Tested with [dstein64/vim-startuptime](https://github.com/dstein64/vim-startuptime) plugin.

<p align="center">
  <img src="https://raw.githubusercontent.com/CharlesChiuGit/nvimdots/main/.github/images/vim-startup.png"
  width = "60%"
  />
</p>

Tested with [rhysd/vim-startuptime](https://github.com/rhysd/vim-startuptime), a CLI tool written in `Go`.

<h3 align="center">
    📸 Script Screenshots
</h3>

<p align="center">
  <img src="https://user-images.githubusercontent.com/32497323/203708095-30ac0243-dcdb-432a-8aff-4d10091422d2.png"
  width = "85%"
  />
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/32497323/203711193-e6bf484c-ba25-4ed7-8e31-afe55442a6ac.png"
  width = "85%"
  />
</p>

# 🪨 Materials

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

### Trendy neovim news

- [This Week In Neovim, aka TWiN](https://this-week-in-neovim.org/), highly recommended
- [Reddit/neovim](https://www.reddit.com/r/neovim/)
- [Twitter/neovim](https://twitter.com/Neovim)
- [Neovim Official News](https://neovim.io/news/), not so up-to-date

# 🎉 Acknowledgment

- [ayamir/nvimdot](https://github.com/ayamir/nvimdots)
- [glepnir/nvim](https://github.com/glepnir/nvim)
- [ChristianChiarulli/nvim](https://github.com/ChristianChiarulli/nvim)
- [ray-x/nvim](https://github.com/ray-x/nvim)
- [folke/dot/config/nvim](https://github.com/folke/dot/tree/master/config/nvim)
- [jdhao/nvim-config](https://github.com/jdhao/nvim-config)
