# NeoVIM config

## Prerequisite

### [bob](https://github.com/MordechaiHadad/bob)

Bob is a cross-platform and easy-to-use neovim version manager, allowing for easy switching between versions right from the command line.

```sh
sudo apt install pkg-config -y # if you are on Linux
cargo install --git https://github.com/MordechaiHadad/bob.git
```

### [nvm](https://github.com/nvm-sh/nvm)

Install & Update Script:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
```

and source it, `source ~/.bashrc`.

Verify Installation:

```bash
command -v nvm
nvm --version
```

※ Noted: `which nvm` will not work if you have not install any version of node, since `nvm` is a sourced shell function, not an executable binary.

```bash
# List all installed Node version
$ nvm ls
->     v16.15.1
default -> lts/* (-> v16.15.1)
iojs -> N/A (default)
unstable -> N/A (default)
node -> stable (-> v16.15.1) (default)
stable -> 16.15 (-> v16.15.1) (default)
```

```bash
# Install LTS version
$ nvm install --lts
# Install latest version
$ nvm install node
```

```bash
# List all available Node.js version
nvm ls-remote
```

```bash
# Change Node.js in one project
# After enter the project folder
# Use this to use the installed version
$ nvm use node
# Or use this to switch to LTS version
$ nvm use --lts
# Or use specific version
$ nvm use v8.2.1
```

```bash
# Run arbitrary node command
nvm run node --version
# Run arbitrary node command with desired version
nvm exec 4.2 node --version
```

---

### [Neovim (github release)](https://github.com/neovim/neovim/releases)

※ Noted: Both **Ubuntu version** and **Snap** has issues with plugins, don't use them.

v0.8.0-dev

```bash
wget https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.deb
sudo apt install ./nvim-linux64.deb
```

**[neovim providers](https://neovim.io/doc/user/provider.html)**

Install python(`:python`) support

```bash
sudo apt install python3-neovim
sudo apt install python3-dev python3-pip
pip3 install pynvim
pip3 install --upgrade pynvim
```

Link python3 to python

```bash
# check if /usr/bin/python exist, if it does, remove it.
ls /usr/bin/ | grep python
# soft link
sudo ln -s /usr/bin/python3 /usr/bin/python
```

Install node support

```sh
npm install neovim --location=global
```

Install perl support

```sh
sudo apt install cpanminus
cpanm --local-lib=~/perl5 local::lib
eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib) # add this line to .bashrc
cpanm -n Neovim::Ext
cpanm -n App::cpanminus
```

Install ruby support

```sh
sudo apt install ruby ruby-dev
sudo gem install neovim
```

If you want to use Neovim for some (or all) of the editor alternatives, use the following commands:

```bash
sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
sudo update-alternatives --config vi
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
sudo update-alternatives --config vim
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor
```

or

In `.bashrc`:

```sh
alias vim='nvim'
export EDITOR='nvim'
```

※ Noted: however, that special interfaces, like `view` for `nvim -R`, are not supported. (See [#1646](https://github.com/neovim/neovim/issues/1646) and [#2008](https://github.com/neovim/neovim/pull/2008).)

---

### Clipboard

- [win32yank](https://github.com/equalsraf/win32yank)

  If you're in WSL, you can use win32yank to access Windows clipboard in nvim. [reference](https://stackoverflow.com/a/67229362/9268330)

  ```vim
  " Use Windows clipboard to copy and to paste
  set clipboard^=unnamed,unnamedplus

  let g:clipboard = {
      \   'name': 'win32yank-wsl',
      \   'copy': {
      \      '+': '/mnt/d/Apps/win32yank-x86/win32yank.exe -i --crlf',
      \      '*': '/mnt/d/Apps/win32yank-x86/win32yank.exe -i --crlf',
      \    },
      \   'paste': {
      \      '+': '/mnt/d/Apps/win32yank-x86/win32yank.exe -o --lf',
      \      '*': '/mnt/d/Apps/win32yank-x86/win32yank.exe -o --lf',
      \   },
      \   'cache_enabled': 0,
      \ }
  ```

  Other workaround, check [this link](https://github.com/neovim/neovim/wiki/FAQ#how-to-use-the-windows-clipboard-from-wsl).

---

### [vim-plug](https://github.com/junegunn/vim-plug)

#### Neovim

###### Unix, Linux

```sh
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

###### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/plug.vim" -Force
```

### Plugins setup

- [tree-sitter](https://tree-sitter.github.io/tree-sitter/creating-parsers#installation)

  ```bash
  npm install tree-sitter-cli
  ```

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

  ```bash
  sudo apt install tar curl git gcc g++ cmake make libstdc++6
  ```

  Python LSP

  ```sh
  pip3 install -U jedi-language-server
  pip3 install pynvim python-lsp-server[all] black vim-vint pyls-isort pylsp-mypy reorder-python-importsy
  ```

- [nvim-lsp-installer](https://github.com/williamboman/nvim-lsp-installer)

  ```sh
  # gvm & Go
  sudo apt-get install curl git mercurial make binutils bison gcc build-essential
  bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
  source ~/.gvm/scripts/gvm
  gvm install go1.18.3 -B
  gvm use go1.18.3 --default

  # cargo & Rust
  curl https://sh.rustup.rs -sSf | sh

  # luarocks & Lua
  https://github.com/luarocks/luarocks/wiki/Installation-instructions-for-Unix

  # composer & php
  sudo apt install php-cli unzip
  sudo apt install composer

  # java & javac
  sudo apt-get install default-jre default-jdk

  # juliaup & julia
  curl -fsSL https://install.julialang.org | sh
  juliaup self update
  juliaup status
  ```

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

  ```sh
  sudo apt-get install ripgrep fd-find fzf
  ```

- [telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim)

  ```sh
  sudo apt install clang make gcc
  ```

- [copilot.vim](https://github.com/github/copilot.vim)

  ```bash
  # Login to github
  :Copilot setup
  ```

- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)

  ```sh
  # lazygit
  https://github.com/jesseduffield/lazygit
  go install github.com/jesseduffield/lazygit@latest
  ```

- [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim)

  ```sh
  sudo apt-get -y install black
  sudo snap install prettier --beta

  # python support
  sudo apt install flake8
  pip install reorder-python-imports
  pip install pylint
  # c support
  sudo apt-get install clang-format
  # lua
  cargo install stylua
  # sh
  sudo apt install shellcheck
  ```

- [vimtex](https://github.com/lervag/vimtex)

  ```sh
  sudo apt install latexmk
  sudo apt install biber
  ```

- [wilder.nvim](https://github.com/gelguy/wilder.nvim)

  ```sh
  sudo pip3 install yarp
  sudo apt install fzy
  ```

- [fzf.lua](https://github.com/ibhagwan/fzf-lua)

  ```sh
  sudo apt install fzf
  sudo apt install fd-find
  sudo apt install ripgrep
  sudo apt install bat
  cargo install git-delta
  cargo install viu
  ```

- [glow.nvim](https://github.com/ellisonleao/glow.nvim)

  ```sh
  wget https://github.com/charmbracelet/glow/releases/download/v1.4.1/glow_1.4.1_linux_amd64.deb
  sudo dpkg -i ~/glow_1.4.1_linux_amd64.deb
  sudo apt-get install -f
  ```

- [nvim-spectre](https://github.com/nvim-pack/nvim-spectre)

  ```sh
  sudo apt-get install ripgrep

  ```

### Plugin bug

- [vim-startify](https://github.com/mhinz/vim-startify)

  Fix `startify: Can't read viminfo file. Read :help startify-faq-02`, [ref](https://github.com/mhinz/vim-startify/issues/306#issuecomment-450303666)

  ```bash
  $ sudo rm ~/.viminfo
  $ vim
  :q
  $ chmod 700 ~/.viminfo
  $ vim
  ```

- `ERROR: Locale does not support UTF-8. Unicode characters may not display correctly.`, [ref](https://github.com/neovim/neovim/issues/1858#issuecomment-70811623)

  Put in your `~/.bashrc`:

  ```sh
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8
  ```

- [`Search and replace across multiply files #18`](https://github.com/nvim-lua/wishlist/issues/18#issuecomment-812092951)

- [For those having hard triggering keymaps. (timeoutlen = 100)](https://github.com/ChristianChiarulli/nvim/issues/30#issue-1275676805)

  ```vim
  set timeoutlen=1000 ttimeoutlen=0
  ```

  ```lua
  vim.opt.timeoutlen = 1000,
  vim.opt.ttimeoutlen = 0,
  ```
