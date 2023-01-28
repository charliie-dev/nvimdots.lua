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
tty_yellow="$(tty_escape "0;33")"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

printf "\n${tty_yellow}====================Script starts====================${tty_reset}\n\n"

NVIM_CONFIG_DIR=$HOME/.config/nvim
printf "${tty_bold}Setting up config and installing plugins${tty_reset}.\n"
if [[ -d "$NVIM_CONFIG_DIR" ]]; then
    mv "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_DIR.backup"
fi

git clone https://github.com/CharlesChiuGit/nvimdots.lua.git "$NVIM_CONFIG_DIR"

printf "${tty_bold}Finished installing Nvim config!${tty_reset}\n\n"

printf "${tty_yellow}====================Script ends====================${tty_reset}\n\n"
