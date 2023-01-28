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
