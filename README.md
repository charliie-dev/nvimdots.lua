# NeoVIM config

## Prerequisite

### [Neovim (github release)](https://github.com/neovim/neovim/releases)

※ NOTE: Both **Ubuntu version** and **Snap** has issues with plugins, don't use them.

※ NOTE: This nvim dotfile applies to v0.8.0-dev and above.

Installation script could be found [here](https://github.com/CharlesChiuGit/nvimdots/blob/4d2dea01eb93fb3e5bc893553750e10f019023f4/docs/nvim_setup_linux.sh#L164).

**[Neovim Providers](https://neovim.io/doc/user/provider.html)**

Install python(`:python`) support, [script](https://github.com/CharlesChiuGit/nvimdots/blob/4d2dea01eb93fb3e5bc893553750e10f019023f4/docs/nvim_setup_linux.sh#L72)

```bash
sudo apt install python3-neovim
sudo apt install python3-dev python3-pip
pip3 install pynvim
pip3 install --upgrade pynvim
```

Install node supports, [script](https://github.com/CharlesChiuGit/nvimdots/blob/4d2dea01eb93fb3e5bc893553750e10f019023f4/docs/nvim_setup_linux.sh#L97)

```sh
npm install neovim --location=global
```

Install perl support, [script](https://github.com/CharlesChiuGit/nvimdots/blob/8ad64c370bab40d4e16b11ee28d5c86c1222082c/docs/nvim_setup_linux.sh#L108)

```sh
cpanm -n Neovim::Ext
cpanm -n App::cpanminus
```

Install ruby support, [script](https://github.com/CharlesChiuGit/nvimdots/blob/8ad64c370bab40d4e16b11ee28d5c86c1222082c/docs/nvim_setup_linux.sh#L117)

```sh
gem install neovim
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

### Plugins setup

Please refer to [nvim_setup_linux.sh](https://github.com/CharlesChiuGit/dotfiles/blob/main/install_scripts/nvim_setup_linux.sh).

### Neovim bugs and workarounds

- `ERROR: Locale does not support UTF-8. Unicode characters may not display correctly.`, [ref](https://github.com/neovim/neovim/issues/1858#issuecomment-70811623)

  Put in your `~/.bashrc`:

  ```sh
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8
  ```

- [`Search and replace across multiply files #18`](https://github.com/nvim-lua/wishlist/issues/18#issuecomment-812092951)

- Why is stylua so hard to pass???
