#!/usr/bin/env bash
# INFO: https://dywang.csie.cyut.edu.tw/dywang/linuxProgram/node61.html
set -exu
set -o pipefail

# Whether to add the path of the installed executables to system PATH
ADD_TO_SYSTEM_PATH=true

# select which shell we are using
USE_BASH_SHELL=true

#######################################################################
#                            batcat part                             #
#######################################################################
BATCAT_DIR=$HOME/tools/batcat
BATCAT_SRC_NAME=$HOME/packages/batcat.tar.gz
BATCAT_LINK="https://github.com/sharkdp/bat/releases/download/v0.21.0/bat-v0.21.0-x86_64-unknown-linux-musl.tar.gz"
if [[ -z "$(command -v bat)" ]] && [[ ! -f "$BATCAT_DIR/bat" ]]; then
	echo "Install batcat"
	if [[ ! -f $BATCAT_SRC_NAME ]]; then
		echo "Downloading batcat and renaming"
		wget $BATCAT_LINK -O "$BATCAT_SRC_NAME"
	fi

	if [[ ! -d "$BATCAT_DIR" ]]; then
		echo "Creating batcat directory under tools directory"
		mkdir -p "$BATCAT_DIR"
		echo "Extracting to $HOME/tools/batcat directory"
		tar zxvf "$BATCAT_SRC_NAME" -C "$BATCAT_DIR" --strip-components 1
	fi

	if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
		echo "export PATH=\"$BATCAT_DIR:\$PATH\"" >>"$HOME/.bashrc"
	fi

	# # set up manpath and zsh completion for batcat
	# mkdir -p $HOME/tools/batcat/doc/man/man1
	# mv $HOME/tools/batcat/doc/rg.1 $HOME/tools/ripgrep/doc/man/man1

else
	echo "batcat is already installed. Skip installing it."
fi

#######################################################################
#                            fdfind part                              #
#######################################################################
FDFIND_DIR=$HOME/tools/fdfind
FDFIND_SRC_NAME=$HOME/packages/fdfind.tar.gz
FDFIND_LINK="https://github.com/sharkdp/fd/releases/download/v8.4.0/fd-v8.4.0-x86_64-unknown-linux-musl.tar.gz"
if [[ -z "$(command -v fd)" ]] && [[ ! -f "$FDFIND_DIR/fd" ]]; then
	echo "Install fdfind"
	if [[ ! -f $FDFIND_SRC_NAME ]]; then
		echo "Downloading fdfind and renaming"
		wget $FDFIND_LINK -O "$FDFIND_SRC_NAME"
	fi

	if [[ ! -d "$FDFIND_DIR" ]]; then
		echo "Creating fdfind directory under tools directory"
		mkdir -p "$FDFIND_DIR"
		echo "Extracting to $HOME/tools/fdfind directory"
		tar zxvf "$FDFIND_SRC_NAME" -C "$FDFIND_DIR" --strip-components 1
	fi

	if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
		echo "export PATH=\"$FDFIND_DIR:\$PATH\"" >>"$HOME/.bashrc"
	fi

else
	echo "fdfind is already installed. Skip installing it."
fi

#######################################################################
#                            fzf part                                 #
#######################################################################
FZF_DIR=$HOME/tools/fzf
FZF_SRC_NAME=$HOME/packages/fzf.tar.gz
FZF_LINK="https://github.com/junegunn/fzf/releases/download/0.33.0/fzf-0.33.0-linux_amd64.tar.gz"
if [[ -z "$(command -v fzf)" ]] && [[ ! -f "$FZF_DIR/fzf" ]]; then
	echo "Install fzf"
	if [[ ! -f $FZF_SRC_NAME ]]; then
		echo "Downloading fzf and renaming"
		wget $FZF_LINK -O "$FZF_SRC_NAME"
	fi

	if [[ ! -d "$FZF_DIR" ]]; then
		echo "Creating fzf directory under tools directory"
		mkdir -p "$FZF_DIR"
		echo "Extracting to $HOME/tools/fzf directory"
		tar zxvf "$FZF_SRC_NAME" -C "$FZF_DIR"
	fi

	if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
		echo "export PATH=\"$FZF_DIR:\$PATH\"" >>"$HOME/.bashrc"
	fi

else
	echo "fzf is already installed. Skip installing it."
fi

#######################################################################
#                            fzy part                                 #
#######################################################################
FZY_DIR=$HOME/tools/fzy
FZY_SRC_NAME=$HOME/packages/fzy.tar.gz
FZY_LINK="https://github.com/jhawthorn/fzy/releases/download/1.0/fzy-1.0.tar.gz"
if [[ -z "$(command -v fzy)" ]] && [[ ! -f "$FZY_DIR/fzy" ]]; then
	echo "Install fzy"
	if [[ ! -f $FZY_SRC_NAME ]]; then
		echo "Downloading fzy and renaming"
		wget $FZY_LINK -O "$FZY_SRC_NAME"
	fi

	if [[ ! -d "$FZY_DIR" ]]; then
		echo "Creating fzy directory under tools directory"
		mkdir -p "$FZY_DIR"
		echo "Extracting to $HOME/tools/fzy directory"
		tar zxvf "$FZY_SRC_NAME" -C "$FZY_DIR" --strip-components 1
		make -C "$FZY_DIR"
	fi

	if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
		echo "export PATH=\"$FZY_DIR:\$PATH\"" >>"$HOME/.bashrc"
	fi

else
	echo "fzy is already installed. Skip installing it."
fi

#######################################################################
#                      git-delta part                                 #
#######################################################################
GITDELTA_DIR=$HOME/tools/git-delta
GITDELTA_SRC_NAME=$HOME/packages/git-delta.tar.gz
GITDELTA_LINK="https://github.com/dandavison/delta/releases/download/0.14.0/delta-0.14.0-x86_64-unknown-linux-musl.tar.gz"
if [[ -z "$(command -v delta)" ]] && [[ ! -f "$GITDELTA_DIR/delta" ]]; then
	echo "Install git-delta"
	if [[ ! -f $GITDELTA_SRC_NAME ]]; then
		echo "Downloading git-delta and renaming"
		wget $GITDELTA_LINK -O "$GITDELTA_SRC_NAME"
	fi

	if [[ ! -d "$GITDELTA_DIR" ]]; then
		echo "Creating git-delta directory under tools directory"
		mkdir -p "$GITDELTA_DIR"
		echo "Extracting to $HOME/tools/git-delta directory"
		tar zxvf "$GITDELTA_SRC_NAME" -C "$GITDELTA_DIR" --strip-components 1
	fi

	if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
		echo "export PATH=\"$GITDELTA_DIR:\$PATH\"" >>"$HOME/.bashrc"
	fi

else
	echo "git-delta is already installed. Skip installing it."
fi

#######################################################################
#                           glow part                                 #
#######################################################################
GLOW_DIR=$HOME/tools/glow
GLOW_SRC_NAME=$HOME/packages/glow.tar.gz
GLOW_LINK="https://github.com/charmbracelet/glow/releases/download/v1.4.1/glow_1.4.1_linux_x86_64.tar.gz"
if [[ -z "$(command -v glow)" ]] && [[ ! -f "$GLOW_DIR/glow" ]]; then
	echo "Install glow"
	if [[ ! -f $GLOW_SRC_NAME ]]; then
		echo "Downloading glow and renaming"
		wget $GLOW_LINK -O "$GLOW_SRC_NAME"
	fi

	if [[ ! -d "$GLOW_DIR" ]]; then
		echo "Creating glow directory under tools directory"
		mkdir -p "$GLOW_DIR"
		echo "Extracting to $HOME/tools/glow directory"
		tar zxvf "$GLOW_SRC_NAME" -C "$GLOW_DIR"
	fi

	if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
		echo "export PATH=\"$GLOW_DIR:\$PATH\"" >>"$HOME/.bashrc"
	fi

else
	echo "glow is already installed. Skip installing it."
fi

#######################################################################
#                        lazygit part                                 #
#######################################################################
LAZYGIT_DIR=$HOME/tools/lazygit
LAZYGIT_SRC_NAME=$HOME/packages/lazygit.tar.gz
LAZYGIT_LINK="https://github.com/jesseduffield/lazygit/releases/download/v0.35/lazygit_0.35_Linux_x86_64.tar.gz"
if [[ -z "$(command -v lazygit)" ]] && [[ ! -f "$LAZYGIT_DIR/lazygit" ]]; then
	echo "Install lazygit"
	if [[ ! -f $LAZYGIT_SRC_NAME ]]; then
		echo "Downloading lazygit and renaming"
		wget $LAZYGIT_LINK -O "$LAZYGIT_SRC_NAME"
	fi

	if [[ ! -d "$LAZYGIT_DIR" ]]; then
		echo "Creating lazygit directory under tools directory"
		mkdir -p "$LAZYGIT_DIR"
		echo "Extracting to $HOME/tools/lazygit directory"
		tar zxvf "$LAZYGIT_SRC_NAME" -C "$LAZYGIT_DIR"
	fi

	if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
		echo "export PATH=\"$LAZYGIT_DIR:\$PATH\"" >>"$HOME/.bashrc"
	fi

else
	echo "lazygit is already installed. Skip installing it."
fi

#######################################################################
#                       LSDeluxe part                                 #
#######################################################################
LSD_DIR=$HOME/tools/lsd
LSD_SRC_NAME=$HOME/packages/lsd.tar.gz
LSD_LINK="https://github.com/Peltoche/lsd/releases/download/0.23.0/lsd-0.23.0-x86_64-unknown-linux-musl.tar.gz"
if [[ -z "$(command -v lsd)" ]] && [[ ! -f "$LSD_DIR/lsd" ]]; then
	echo "Install lsd"
	if [[ ! -f $LSD_SRC_NAME ]]; then
		echo "Downloading lsd and renaming"
		wget $LSD_LINK -O "$LSD_SRC_NAME"
	fi

	if [[ ! -d "$LSD_DIR" ]]; then
		echo "Creating lsd directory under tools directory"
		mkdir -p "$LSD_DIR"
		echo "Extracting to $HOME/tools/lsd directory"
		tar zxvf "$LSD_SRC_NAME" -C "$LSD_DIR" --strip-components 1
	fi

	if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
		echo "export PATH=\"$LSD_DIR:\$PATH\"" >>"$HOME/.bashrc"
	fi

else
	echo "lsd is already installed. Skip installing it."
fi

#######################################################################
#                            Ripgrep part                             #
#######################################################################
RIPGREP_DIR=$HOME/tools/ripgrep
RIPGREP_SRC_NAME=$HOME/packages/ripgrep.tar.gz
RIPGREP_LINK="https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz"
if [[ -z "$(command -v rg)" ]] && [[ ! -f "$RIPGREP_DIR/rg" ]]; then
	echo "Install ripgrep"
	if [[ ! -f $RIPGREP_SRC_NAME ]]; then
		echo "Downloading ripgrep and renaming"
		wget $RIPGREP_LINK -O "$RIPGREP_SRC_NAME"
	fi

	if [[ ! -d "$RIPGREP_DIR" ]]; then
		echo "Creating ripgrep directory under tools directory"
		mkdir -p "$RIPGREP_DIR"
		echo "Extracting to $HOME/tools/ripgrep directory"
		tar zxvf "$RIPGREP_SRC_NAME" -C "$RIPGREP_DIR" --strip-components 1
	fi

	if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
		echo "export PATH=\"$RIPGREP_DIR:\$PATH\"" >>"$HOME/.bashrc"
	fi

	# # set up manpath and zsh completion for ripgrep
	# mkdir -p $HOME/tools/ripgrep/doc/man/man1
	# mv $HOME/tools/ripgrep/doc/rg.1 $HOME/tools/ripgrep/doc/man/man1

	# if [[ "$USE_BASH_SHELL" = true ]]; then
	# 	echo 'export MANPATH=$HOME/tools/ripgrep/doc/man:$MANPATH' >>"$HOME/.bashrc"
	# else
	# 	echo 'export MANPATH=$HOME/tools/ripgrep/doc/man:$MANPATH' >>"$HOME/.zshrc"
	# 	echo 'export FPATH=$HOME/tools/ripgrep/complete:$FPATH' >>"$HOME/.zshrc"
	# fi
else
	echo "ripgrep is already installed. Skip installing it."
fi

#######################################################################
#                       tree-sitter part                              #
#######################################################################
TS_DIR=$HOME/tools/treesitter
TS_SRC_NAME=$HOME/packages/tree-sitter-linux-x64.gz
TS_LINK="https://github.com/tree-sitter/tree-sitter/releases/download/v0.20.7/tree-sitter-linux-x64.gz"
if [[ -z "$(command -v tree-sitter)" ]] && [[ ! -f "$TS_DIR/tree-sitter" ]]; then
	echo "Install treesitter"
	if [[ ! -f $TS_SRC_NAME ]]; then
		echo "Downloading treesitter and renaming"
		wget $TS_LINK -P "$HOME/packages"
	fi

	if [[ ! -d "$TS_DIR" ]]; then
		echo "Creating tree-sitter directory under tools directory"
		mkdir -p "$TS_DIR"
		echo "Extracting to $HOME/tools/treesitter directory"
		gunzip "$TS_SRC_NAME"
		mv "$HOME/packages/tree-sitter-linux-x64" "$TS_DIR/tree-sitter"
		chmod u+x "$TS_DIR/tree-sitter"
	fi

	if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
		echo "export PATH=\"$TS_DIR:\$PATH\"" >>"$HOME/.bashrc"
	fi

else
	echo "tree-sitter is already installed. Skip installing it."
fi

#######################################################################
#                            viu part                                 #
#######################################################################
VIU_DIR=$HOME/tools/viu
VIU_LINK="https://github.com/atanunq/viu/releases/download/v1.4.0/viu"
if [[ -z "$(command -v viu)" ]] && [[ ! -f "$VIU_DIR/viu" ]]; then
	echo "Install viu"
	echo "Downloading viu and renaming"
	wget $VIU_LINK -P "$HOME/packages"

	if [[ ! -d "$VIU_DIR" ]]; then
		echo "Creating viu directory under tools directory"
		mkdir -p "$VIU_DIR"
		mv "$HOME/packages/viu" "$VIU_DIR/"
		chmod +x "$VIU_DIR/viu"
	fi

	if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
		echo "export PATH=\"$VIU_DIR:\$PATH\"" >>"$HOME/.bashrc"
	fi

else
	echo "viu is already installed. Skip installing it."
fi

#######################################################################
#                         zoxide part                                 #
#######################################################################
ZOXIDE_DIR=$HOME/tools/zoxide
ZOXIDE_SRC_NAME=$HOME/packages/zoxide.tar.gz
ZOXIDE_LINK="https://github.com/ajeetdsouza/zoxide/releases/download/v0.8.3/zoxide-0.8.3-x86_64-unknown-linux-musl.tar.gz"
if [[ -z "$(command -v zoxide)" ]] && [[ ! -f "$ZOXIDE_DIR/zoxide" ]]; then
	echo "Install zoxide"
	if [[ ! -f $ZOXIDE_SRC_NAME ]]; then
		echo "Downloading zoxide and renaming"
		wget $ZOXIDE_LINK -O "$ZOXIDE_SRC_NAME"
	fi

	if [[ ! -d "$ZOXIDE_DIR" ]]; then
		echo "Creating zoxide directory under tools directory"
		mkdir -p "$ZOXIDE_DIR"
		echo "Extracting to $HOME/tools/zoxide directory"
		tar zxvf "$ZOXIDE_SRC_NAME" -C "$ZOXIDE_DIR"
		##chmod +x "$ZOXIDE_DIR/zoxide.bash"
		##ln -s "$ZOXIDE_DIR/zoxide.bash" "$ZOXIDE_DIR/zoxide"
	fi

	if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
		echo "export PATH=\"$ZOXIDE_DIR:\$PATH\"" >>"$HOME/.bashrc"
	fi

else
	echo "zoxide is already installed. Skip installing it."
fi

source "$HOME/.bashrc"
