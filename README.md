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
        src="https://img.shields.io/github/issues-raw/CharlesChiuGit/nvimdots?color=%23DCA561&label=%EF%85%85%20ISSUES&style=for-the-badge">
    </a>
    <a href="https://github.com/CharlesChiuGit/nvimdots/contributors">
    <img
        alt="GitHub contributors"
        src="https://img.shields.io/github/contributors/CharlesChiuGit/nvimdots?color=%2398BB6C&logo=opensourceinitiative&logoColor=d9e0ee&style=for-the-badge">
    </a>
    <img
        alt="GitHub code size in bytes"
        src="https://img.shields.io/github/languages/code-size/CharlesChiuGit/nvimdots?color=7E9CD8&label=%EF%84%A1%20Code&logo=code&style=for-the-badge">
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/CharlesChiuGit/nvimdots/main/.github/images/alpha-full.png"
  width = "90%"
  />
</p>

<blockquote align="center">
    R.I.P. Kentaro Miura sensei 🥀
</blockquote>

---

# 🎐 Intro

- **⚡BLAZINGLY FAST** startup time in ~20ms, with over 100 plugins. (Tested on Micron Crucial MX500)
- Well structured in `Lua`.
- Easy to customize.
- Automized [installation scripts](https://github.com/CharlesChiuGit/dotfiles/blob/main/install_scripts/nvim_setup_linux.sh)(in my other dotfile repo), written in `bash`.
- 100% lazy-loading. Ok, I lied. You can't really lazy-load the theme, UI will look weird.
- Use [delaytrain.nvim](https://github.com/ja-ford/delaytrain.nvim) to train yourself into a better vimmer, disable it if you want.
- Aligned icons across every plugin!

# 🧱 Structure

```txt
├── after/
│   ├── ftplugin/                  filetype-based rules
│   └── queries/                   treesitter injection
├── fonts/                         nerdfonts
├── ftdetect/                      filetype detection
├── init.lua
├── lua/
│   ├── core/
│   │   ├── event.lua              event-based autocommands
│   │   ├── global.lua             global variables
│   │   ├── init.lua
│   │   ├── mapping.lua            basic keymaps
│   │   ├── options.lua            neovim options
│   │   └── pack.lua               custom packer wrapper
│   ├── keymap/                    plugin-related keymaps
│   └── modules/                   plugin-configs
│       ├── completion/
│       │   ├── plugins.lua
│       │   └── server-settings/   settings for each LSP
│       ├── editor/
│       │   └── plugins.lua
│       ├── lang
│       │   └── plugins.lua
│       ├── tools/
│       │   ├── dap/               DAP settings for each language
│       │   └── plugins.lua
│       └── ui/
│           └── plugins.lua
├── snippets/
│   └── package.json               define how `LuaSnip` read snippets, vscode-style
├── spell/                         custom spelling correction
└── stylua.toml                    stylua settings
```

NOTE: You can rename each folder inside `modules`, but **ALWAYS** remember to add a `plugins.lua` in it to register your plugins.

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

Brief intro of [Core Keymaps](https://github.com/CharlesChiuGit/nvimdots/wiki/Keymaps). (WIP)

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

Tested with [rhysd/vim-startuptime](https://github.com/rhysd/vim-startuptime), a cli tool written in `Go`.

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
  - [BooleanCube/NeovimKeys](https://github.com/BooleanCube/NeovimKeys), offline vim motion game

### Youtube channels

- [ThePrimeagen/Vim As Your Editor](https://www.youtube.com/playlist?list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R)
- [TJ DeVries](https://www.youtube.com/c/TJDeVries/playlists)

### Awesomes

- [neovimcraft](https://neovimcraft.com)
- [LibHunt/neovim](https://www.libhunt.com/search?query=neovim)
- [rockerBOO/awesome-neovim](https://github.com/rockerBOO/awesome-neovim)

### Trendy neovim news

- [This Week In Neovim, aka TWiN](https://this-week-in-neovim.org/), highly recommended
- [Reddit/neovim](https://www.reddit.com/r/neovim/)
- [Twitter/neovim](https://twitter.com/Neovim)
- [Neovim Offical News](https://neovim.io/news/), not so up-to-date

# 🎉 Acknowledgment

- [ayamir/nvimdot](https://github.com/ayamir/nvimdots)
- [glepnir/nvim](https://github.com/glepnir/nvim)
- [ChristianChiarulli/nvim](https://github.com/ChristianChiarulli/nvim)
- [ray-x/nvim](https://github.com/ray-x/nvim)
- [folke/dot/config/nvim](https://github.com/folke/dot/tree/master/config/nvim)
- [jdhao/nvim-config](https://github.com/jdhao/nvim-config)
