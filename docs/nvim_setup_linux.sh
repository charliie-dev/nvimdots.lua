#!/bin/bash -i
# INFO: https://dywang.csie.cyut.edu.tw/dywang/linuxProgram/node61.html
set -exu
set -o pipefail

# Whether to add the path of the installed executables to system PATH
ADD_TO_SYSTEM_PATH=false

# select which shell we are using
USE_BASH_SHELL=true

if [[ ! -d "$HOME/packages/" ]]; then
    mkdir -p "$HOME/packages/"
fi

if [[ ! -d "$HOME/tools/" ]]; then
    mkdir -p "$HOME/tools/"
fi

#######################################################################
#                    Anaconda or miniconda install                    #
#######################################################################

# Whether python3 has been installed on the system
PYTHON_INSTALLED=true

# If Python has been installed, then we need to know whether Python is provided
# by the system, or you have already installed Python under your HOME.
SYSTEM_PYTHON=false

# If SYSTEM_PYTHON is false, we need to decide whether to install
# Anaconda (INSTALL_ANACONDA=true) or Miniconda (INSTALL_ANACONDA=false)
INSTALL_ANACONDA=true

if [[ "$INSTALL_ANACONDA" = true ]]; then
    CONDA_DIR=$HOME/tools/anaconda
    CONDA_NAME=Anaconda.sh
    CONDA_LINK="https://repo.anaconda.com/archive/Anaconda3-2022.05-Linux-x86_64.sh"
else
    CONDA_DIR=$HOME/tools/miniconda
    CONDA_NAME=Miniconda.sh
    CONDA_LINK="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
fi

if [[ ! "$PYTHON_INSTALLED" = true ]]; then
    echo "Installing Python in user HOME"
    
    SYSTEM_PYTHON=false
    
    echo "Downloading and installing conda"
    
    if [[ ! -f "$HOME/packages/$CONDA_NAME" ]]; then
        curl -Lo "$HOME/packages/$CONDA_NAME" $CONDA_LINK
    fi
    
    # Install conda silently
    if [[ -d $CONDA_DIR ]]; then
        rm -rf "$CONDA_DIR"
    fi
    bash "$HOME/packages/$CONDA_NAME" -b -p "$CONDA_DIR"
    
    # Setting up environment variables
    if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
        echo "export PATH=\"$CONDA_DIR/bin:\$PATH\"" >>"$HOME/.bashrc"
        export PATH="$CONDA_DIR/bin:$PATH"
    fi
else
    echo "Python is already installed. Skip installing it."
fi

# Install some Python packages used by Nvim plugins.
echo "Installing Python packages"
declare -a py_packages=("pynvim" "yarp")

if [[ "$SYSTEM_PYTHON" = true ]]; then
    echo "Using system Python to install $(PY_PACKAGES)"
    
    # If we use system Python, we need to install these Python packages under
    # user HOME, since we do not have permissions to install them under system
    # directories.
    for p in "${py_packages[@]}"; do
        pip3 install --user "$p"
    done
else
    echo "Using custom Python to install $(PY_PACKAGES)"
    for p in "${py_packages[@]}"; do
        "$CONDA_DIR/bin/pip3" install "$p"
    done
fi

#######################################################################
#                      Node install packages                          #
#######################################################################
NODE_DIR=$HOME/tools/nodejs

# Install neovim support for node plugins
"$NODE_DIR/bin/npm" install neovim --location=global

# Install tree-sitter-cli
# "$NODE_DIR/bin/npm" install tree-sitter-cli --location=global

#######################################################################
#                  Perl/cpanm install packages                        #
#######################################################################
PERL_DIR=$HOME/tools/perl
CPANM_DIR=$PERL_DIR/bin/cpanm

"$CPANM_DIR" -n Neovim::Ext
"$CPANM_DIR" -n App::cpanminus


#######################################################################
#                   Ruby/gem install packages                         #
#######################################################################
RUBY_DIR=$HOME/tools/ruby

"$RUBY_DIR/bin/gem" install neovim


#######################################################################
#                      Go install packages                            #
#######################################################################
GVM_DIR=$HOME/.gvm

# "$GVM_DIR/gos/go1.19.1/bin/go" install

#######################################################################
#                   Rust/cargo install packages                       #
#######################################################################
RUSTUP_HOME=$HOME/tools/rustup
CARGO_HOME=$HOME/tools/cargo

# "$CARGO_HOME/bin/cargo" install

#######################################################################
#                      Java install packages                          #
#######################################################################
JDK_DIR=$HOME/tools/jdk

# "$JDK_DIR/bin/java" install

#######################################################################
#                     Julia install packages                          #
#######################################################################
JULIA_DIR=$HOME/tools/julia

# "$JULIA_DIR/bin/julia" install

#######################################################################
#             Lua, LuaJIT/luarocks install packages                   #
#######################################################################
LUA_DIR=$HOME/tools/lua
LUAJIT_DIR=$HOME/tools/luajit
LUAROCKS_DIR=$HOME/tools/luarocks/luarocks


#######################################################################
#                 PHP/composer install packages                       #
#######################################################################
PHP_DIR=$HOME/tools/php
COMPOSER_DIR=$PHP_DIR/bin/composer

# "$COMPOSER_DIR" install

#######################################################################
#                           Nvim install                              #
#######################################################################
NVIM_DIR=$HOME/tools/nvim
NVIM_SRC_NAME=$HOME/packages/nvim-linux64.tar.gz
NVIM_CONFIG_DIR=$HOME/.config/nvim
NVIM_LINK="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz"
if [[ ! -f "$NVIM_DIR/bin/nvim" ]]; then
    echo "Installing Nvim"
    echo "Creating nvim directory under tools directory"
    
    if [[ ! -d "$NVIM_DIR" ]]; then
        mkdir -p "$NVIM_DIR"
    fi
    
    if [[ ! -f $NVIM_SRC_NAME ]]; then
        echo "Downloading Nvim"
        wget "$NVIM_LINK" -O "$NVIM_SRC_NAME"
    fi
    echo "Extracting neovim"
    tar zxvf "$NVIM_SRC_NAME" --strip-components 1 -C "$NVIM_DIR"
    
    if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
        echo "export PATH=\"$NVIM_DIR/bin:\$PATH\"" >>"$HOME/.bashrc"
        export PATH="$NVIM_DIR/bin:$PATH"
    fi
else
    echo "Nvim is already installed. Skip installing it."
fi

echo "Setting up config and installing plugins"
if [[ -d "$NVIM_CONFIG_DIR" ]]; then
    mv "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_DIR.backup"
fi

git clone https://github.com/CharlesChiuGit/nvimdots.git "$NVIM_CONFIG_DIR"

echo "Installing packer.nvim"
if [[ ! -d ~/.local/share/nvim/site/pack/packer/opt/packer.nvim ]]; then
    git clone --depth=1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim
fi

echo "Installing nvim plugins, please wait"
"$NVIM_DIR/bin/nvim" -c "autocmd User PackerComplete quitall" -c "PackerSync"

echo "Finished installing Nvim and its dependencies!"
