#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

abort() {
	printf "%s\n" "$@" >&2
	exit 1
}

# string formatters
if [[ -t 1 ]]; then
	tty_escape() { printf "\033[%sm" "$1"; }
else
	tty_escape() { :; }
fi

tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_yellow="$(tty_escape "0;33")"
tty_red="$(tty_mkbold 31)"
tty_green="$(tty_mkbold 32)"
tty_blue="$(tty_mkbold 34)"
tty_magenta="$(tty_mkbold 35)"
tty_cyan="$(tty_mkbold 36)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

printf "\n${tty_yellow}====================Script starts====================${tty_reset}\n\n"

######################################################################
#                      Install Python packages                       #
######################################################################
printf "Installing ${tty_magenta}Python${tty_reset} packages via ${tty_yellow}pip${tty_reset}.\n"
# INFO: klepto is needed by Sniprun
declare -a py_packages=("wheel" "pynvim" "klepto" "rich")

printf "Using ${tty_blue}system${tty_reset} Python to install ${tty_green}${py_packages[*]}${tty_reset}\n"

# If we use system Python, we need to install these Python packages under
# user HOME, since we do not have permissions to install them under system
# directories.
for p in "${py_packages[@]}"; do
	pip3 install --user "$p" -q
done

printf "Using ${tty_cyan}conda${tty_reset} Python to install ${tty_green}${py_packages[*]}${tty_reset}\n"
for p in "${py_packages[@]}"; do
	"$CONDA_DIR/bin/pip3" install "$p" -q
done

printf "Done.\n\n"

######################################################################
#                       Install Node packages                        #
######################################################################
printf "Installing ${tty_magenta}Node${tty_reset} packages.\n"

npm install npm@latest --location=global --silent
# Install neovim support for node plugins
npm install neovim --location=global --silent

# Add for markdown-preview.nvim
npm install tslib --location=global --silent

printf "Done.\n\n"

######################################################################
#                    Install Perl/cpanm packages                     #
######################################################################
printf "Installing ${tty_magenta}Perl${tty_reset} packages via ${tty_yellow}cpanm${tty_reset}.\n"
PERL_DIR=$HOME/tools/perl
CPANM_DIR=$PERL_DIR/bin/cpanm

"$CPANM_DIR" -n Neovim::Ext --quiet
"$CPANM_DIR" -n App::cpanminus --quiet

printf "Done.\n\n"

######################################################################
#                     Install Ruby/gem packages                      #
######################################################################
printf "Installing ${tty_magenta}Ruby${tty_reset} packages via ${tty_yellow}gem${tty_reset}.\n"
RUBY_DIR=$HOME/tools/ruby

"$RUBY_DIR/bin/gem" install neovim --silent

printf "Done.\n\n"

######################################################################
#                        Install Go packages                         #
######################################################################
# GVM_DIR=$HOME/.gvm

# "$GVM_DIR/gos/go1.19.1/bin/go" install

######################################################################
#                    Install Rust/cargo packages                     #
######################################################################

######################################################################
#                       Install Java packages                        #
######################################################################
# JDK_DIR=$HOME/tools/java

# "$JDK_DIR/bin/java" install

######################################################################
#                       Install Julia packages                       #
######################################################################
# JULIA_DIR=$HOME/tools/julia

# "$JULIA_DIR/bin/julia" install

######################################################################
#                Install Lua/LuaJIT/Luarocks packages                #
######################################################################
printf "Installing ${tty_magenta}Lua${tty_reset} packages via ${tty_yellow}luarocks${tty_reset}.\n"
# LUA_DIR=$HOME/tools/lua
# LUAJIT_DIR=$HOME/tools/luajit
LUAROCKS_DIR=$HOME/tools/luarocks/luarocks

# for kkharji/sqlite.lua
"$LUAROCKS_DIR" install luv
"$LUAROCKS_DIR" install sqlite
# for jakewvincent/mkdnflow.nvim
"$LUAROCKS_DIR" install luautf8

printf "Done.\n\n"

######################################################################
#                   Install PHP/composer packages                    #
######################################################################
# PHP_DIR=$HOME/tools/php
# COMPOSER_DIR=$PHP_DIR/bin/composer

# "$COMPOSER_DIR" install

######################################################################
#                    win32yank for Neovim in WSL                     #
######################################################################
USE_WSL=false
if [[ "$USE_WSL" = true ]]; then
	printf "Installing ${tty_magenta}win32yank${tty_reset} for ${tty_red}WSL${tty_reset} ${tty_underline}clipboard${tty_reset}.\n"

	curl -sLo/tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
	unzip -p /tmp/win32yank.zip win32yank.exe >/tmp/win32yank.exe
	chmod +x /tmp/win32yank.exe
	sudo mv /tmp/win32yank.exe /usr/local/bin/

	printf "Done.\n\n"
fi
# NOTE: don't forget to `set clipboard=unnamedplus`

######################################################################
#                           Neovim Config                            #
######################################################################

if ! command -v nvim >/dev/null; then
	abort "$(
		cat <<EOABORT
You must install NeoVim before installing this Nvim config. See:
  ${tty_underline}https://github.com/neovim/neovim/wiki/Installing-Neovim${tty_reset}
EOABORT
	)"
fi

NVIM_DIR=$HOME/tools/nvim
NVIM_CONFIG_DIR=$HOME/.config/nvim
printf "${tty_bold}Setting up config and installing plugins${tty_reset}.\n"
if [[ -d "$NVIM_CONFIG_DIR" ]]; then
	mv "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_DIR.backup"
fi

git clone git@github.com:CharlesChiuGit/nvimdots.lua.git "$NVIM_CONFIG_DIR"

printf "Installing nvim plugins, please wait\n"
"$NVIM_DIR/bin/nvim" -c "+Lazy sync"
printf "Done.\n\n"

printf "${tty_bold}Finished installing Nvim config and its dependencies!${tty_reset}\n\n"

printf "${tty_yellow}====================Script ends====================${tty_reset}\n\n"

cat <<EOS

- Project Homepage:
    ${tty_green}https://github.com/CharlesChiuGit/nvimdots.lua${tty_reset}
- Further documentation (including executables you ${tty_red}must${tty_reset} install for full functionality):
    ${tty_green}https://github.com/CharlesChiuGit/nvimdots.lua/wiki/Prerequisite${tty_reset}
- File an issue if you encounter any problems.
    ${tty_green}https://github.com/CharlesChiuGit/nvimdots.lua/issues${tty_reset}

EOS
