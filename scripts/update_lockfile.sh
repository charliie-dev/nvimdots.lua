#!/usr/bin/env bash
# CI-only: symlinks the checked-out workspace to ~/.config/nvim so Neovim
# finds its configuration (lazy.nvim, etc.) in the expected location.
# WARNING: Do NOT run locally — it will remove ~/.config/nvim.
set -euo pipefail

if [[ -z "${CI:-}" ]]; then
	echo "ERROR: This script is intended for CI only." >&2
	exit 1
fi

NVIM_CONFIG_DIR="$HOME/.config/nvim"

mkdir -p "$(dirname "$NVIM_CONFIG_DIR")"

if [[ -d "$NVIM_CONFIG_DIR" || -L "$NVIM_CONFIG_DIR" ]]; then
	rm -rf "$NVIM_CONFIG_DIR"
fi

ln -sfn "${GITHUB_WORKSPACE:-.}" "$NVIM_CONFIG_DIR"
echo "Linked $NVIM_CONFIG_DIR -> $(readlink "$NVIM_CONFIG_DIR")"
