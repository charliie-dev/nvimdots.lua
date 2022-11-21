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

######################################################################
#                          Git repo update                           #
######################################################################
# HACK: https://stackoverflow.com/a/3278427/9268330
check_git_update() {
    UPSTREAM=${1:-'@{u}'} # optionally to pass an upstream branch explicitly. if none, use origin/main
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")

    if [ "$LOCAL" = "$REMOTE" ]; then
        # printf "Up-to-date\n"
        echo false
    elif [ "$LOCAL" = "$BASE" ]; then
        # printf "Need to pull\n"
        echo true
    elif [ "$REMOTE" = "$BASE" ]; then
        # printf "Need to push\n"
        echo false
    else
        # printf "Diverged\n"
        echo false
    fi
}

printf "\n${tty_yellow}====================Script starts====================${tty_reset}\n\n"

######################################################################
#                          Update nvimdots                           #
######################################################################
NVIM_DIR=$HOME/tools/nvim
NVIM_CONFIG_DIR=$HOME/.config/nvim

printf "Fetch ${tty_blue}CharlesChiuGit/nvimdots.lua${tty_reset} commits...\n"

cd "$NVIM_CONFIG_DIR"
git fetch
status=$(check_git_update "")

if [[ $status = true ]]; then
    printf "Update ${tty_blue}CharlesChiuGit/nvimdots.lua${tty_reset}"
    git pull
    printf "Updateing nvim plugins, please wait\n"
    "$NVIM_DIR/bin/nvim" -c "autocmd User PackerComplete quitall" -c "PackerSync"
    printf "Done.\n"
elif [[ $status = false ]]; then
    printf "${tty_blue}CharlesChiuGit/nvimdots.lua${tty_reset} is up-to-date!\n"
fi

printf "${tty_bold}Finished updating Nvim config!${tty_reset}\n\n"

printf "${tty_yellow}====================Script ends====================${tty_reset}\n\n"

cat <<EOS

- Project Homepage:
    ${tty_green}https://github.com/CharlesChiuGit/nvimdots.lua${tty_reset}
- Further documentation (including executables you ${tty_red}must${tty_reset} install for full functionality):
    ${tty_green}https://github.com/CharlesChiuGit/nvimdots.lua/wiki/Prerequisite${tty_reset}
- File an issue if you encounter any problems.
    ${tty_green}https://github.com/CharlesChiuGit/nvimdots.lua/issues${tty_reset}

EOS
