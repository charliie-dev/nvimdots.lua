#!/bin/bash
# INFO: https://dywang.csie.cyut.edu.tw/dywang/linuxProgram/node61.html
set -eu
set -o pipefail

# Whether to add the path of the installed executables to system PATH
ADD_TO_SYSTEM_PATH=true

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
# SYSTEM_PYTHON=false

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

#######################################################################
#                           Install node                              #
#######################################################################
NODE_DIR=$HOME/tools/nodejs
NODE_SRC_NAME=$HOME/packages/nodejs.tar.gz
NODE_LINK="https://nodejs.org/dist/v16.16.0/node-v16.16.0-linux-x64.tar.xz"
if [[ -z "$(command -v node)" ]]; then
    echo "Install Node.js"
    if [[ ! -f $NODE_SRC_NAME ]]; then
        echo "Downloading Node.js and renaming"
        wget $NODE_LINK -O "$NODE_SRC_NAME"
    fi
    
    if [[ ! -d "$NODE_DIR" ]]; then
        echo "Creating Node.js directory under tools directory"
        mkdir -p "$NODE_DIR"
        echo "Extracting to $HOME/tools/nodejs directory"
        tar xvf "$NODE_SRC_NAME" -C "$NODE_DIR" --strip-components 1
    fi
    
    if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
        echo "export PATH=\"$NODE_DIR/bin:\$PATH\"" >>"$HOME/.bashrc"
        export PATH="$NODE_DIR/bin:$PATH"
        npm config set fund false
    fi
else
    echo "Node.js is already installed. Skip installing it."
fi

#######################################################################
#                      Install Perl & cpanm                           #
#######################################################################
PERL_DIR=$HOME/tools/perl
PERL_SRC_NAME=$HOME/packages/perl.tar.gz
PERL_LINK="https://www.cpan.org/src/5.0/perl-5.36.0.tar.gz"
CPANM_DIR=$HOME/tools/cpanm

if [[ "$(command which perl)" = "/usr/bin/perl" ]]; then
    echo "Install perl"
    if [[ ! -f $PERL_SRC_NAME ]]; then
        echo "Downloading Perl and renaming"
        wget $PERL_LINK -O "$PERL_SRC_NAME"
    fi
    
    if [[ ! -d "$PERL_DIR" ]]; then
        echo "Creating Perl directory under tools directory"
        mkdir -p "$PERL_DIR"
        mkdir -p "$CPANM_DIR"
        echo "Extracting to $HOME/tools/perl directory"
        tar xvf "$PERL_SRC_NAME" -C "$PERL_DIR" --strip-components 1
        cd "$PERL_DIR"
        ./Configure -des -Dprefix="$PERL_DIR"
        make
        make install
        
        echo "Install cpanm"
        export PERL_CPANM_HOME="$CPANM_DIR"
        curl -L https://cpanmin.us | "$PERL_DIR/bin/perl" - App::cpanminus
    fi
    
    if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
        echo "export PATH=\"$PERL_DIR/bin:\$PATH\"" >>"$HOME/.bashrc"
        export PATH="$PERL_DIR/bin:$PATH"
    fi
    
else
    echo "Perl is already installed. Skip installing it."
fi

#######################################################################
#                         Install Ruby & gem                          #
#######################################################################
RUBY_DIR=$HOME/tools/ruby
RUBY_TAR_DIR=$HOME/tools/ruby/tarball
RUBY_SRC_NAME=$HOME/packages/ruby.tar.gz
RUBY_LINK="https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.2.tar.gz"
if [[ -z "$(command -v ruby)" ]]; then
    echo "Install Ruby"
    if [[ ! -f $RUBY_SRC_NAME ]]; then
        echo "Downloading ruby and renaming"
        wget $RUBY_LINK -O "$RUBY_SRC_NAME"
    fi
    
    if [[ ! -d "$RUBY_DIR" ]]; then
        echo "Creating ruby directory under tools directory"
        mkdir -p "$RUBY_DIR"
        mkdir -p "$RUBY_TAR_DIR"
        echo "Extracting to $HOME/tools/ruby/tarball directory"
        tar xvf "$RUBY_SRC_NAME" -C "$RUBY_TAR_DIR" --strip-components 1
        cd "$RUBY_TAR_DIR"
        ./configure --prefix="$RUBY_DIR"
        make
        make install
        
    fi
    
    if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
        echo "export PATH=\"$RUBY_DIR/bin:\$PATH\"" >>"$HOME/.bashrc"
        export PATH="$RUBY_DIR/bin:$PATH"
    fi
    
else
    echo "Ruby is already installed. Skip installing it."
fi

#######################################################################
#                          Install Go                                 #
#######################################################################
GO_DIR=$HOME/tools/golang
GO_SRC_NAME=$HOME/packages/golang.tar.gz
GO_LINK="https://go.dev/dl/go1.19.1.linux-amd64.tar.gz"
if [[ -z "$(command -v go)" ]]; then
    echo "Install Golang"
    if [[ ! -f $GO_SRC_NAME ]]; then
        echo "Downloading go and renaming"
        wget $GO_LINK -O "$GO_SRC_NAME"
    fi
    
    if [[ ! -d "$GO_DIR" ]]; then
        echo "Creating golang directory under tools directory"
        mkdir -p "$GO_DIR"
        echo "Extracting to $HOME/tools/golang directory"
        tar xvf "$GO_SRC_NAME" -C "$GO_DIR" --strip-components 1
    fi
    
    if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
        echo "export PATH=\"$GO_DIR/bin:\$PATH\"" >>"$HOME/.bashrc"
        export PATH="$GO_DIR/bin:$PATH"
    fi
else
    echo "Golang is already installed. Skip installing it."
fi


#######################################################################
#                   Install cargo for Rust                            #
#######################################################################
RUSTUP_HOME=$HOME/tools/rustup
CARGO_HOME=$HOME/tools/cargo

if [[ -z "$(command -v cargo)" ]]; then
    
    if [[ ! -d "$CARGO_HOME" ]]; then
        echo "Creating rustup & cargo directory under tools directory"
        mkdir -p "$RUSTUP_HOME"
        mkdir -p "$CARGO_HOME"
        if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
            echo "export RUSTUP_HOME=$RUSTUP_HOME" >>"$HOME/.bashrc"
            echo "export CARGO_HOME=$CARGO_HOME" >>"$HOME/.bashrc"
            export RUSTUP_HOME=$RUSTUP_HOME
            export CARGO_HOME=$CARGO_HOME
        fi
        echo "Installing rustup"
        curl https://sh.rustup.rs -sSf | sh -s -- -y
        
        
        if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
            echo "export PATH=\"$CARGO_HOME/bin:\$PATH\"" >>"$HOME/.bashrc"
            export PATH="$CARGO_HOME/bin:$PATH"
        fi
        
        export PATH="$CARGO_HOME/bin:$PATH"
        echo "Install cargo"
        "$CARGO_HOME/bin/rustup" default stable
        # Configure current shell
        source "$CARGO_HOME/env"
    fi
    
fi

#######################################################################
#                       Install Java, JDK                             #
#######################################################################
JDK_DIR=$HOME/tools/jdk
JDK_SRC_NAME=$HOME/packages/jdk.tar.gz
JDK_LINK="https://download.java.net/java/GA/jdk18.0.2/f6ad4b4450fd4d298113270ec84f30ee/9/GPL/openjdk-18.0.2_linux-x64_bin.tar.gz"
if [[ -z "$(command -v java)" ]]; then
    echo "Install JDK"
    if [[ ! -f $JDK_SRC_NAME ]]; then
        echo "Downloading JDK"
        wget "$JDK_LINK" -O "$JDK_SRC_NAME"
    fi
    
    if [[ ! -d "$JDK_DIR" ]]; then
        echo "Creating JDK directory under tools directory"
        mkdir -p "$JDK_DIR"
        echo "Extracting JDK"
        tar -xvf "$JDK_SRC_NAME" -C "$JDK_DIR" --strip-components 1
    fi
    
    if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
        echo "export PATH=\"$JDK_DIR/bin:\$PATH\"" >>"$HOME/.bashrc"
        export PATH="$JDK_DIR/bin:$PATH"
    fi
else
    echo "JDK is already installed. Skip installing it."
    
fi

#######################################################################
#                          Install Julia                              #
#######################################################################
# JULIA_DIR=$HOME/tools/julia
# JULIA_SRC_NAME=$HOME/packages/julia.tar.gz
# JULIA_LINK="https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz"
# if [[ -z "$(command -v julia)" ]]; then
#     echo "Install Julia"
#     if [[ ! -f $JULIA_SRC_NAME ]]; then
#         echo "Downloading Julia"
#         wget "$JULIA_LINK" -O "$JULIA_SRC_NAME"
#     fi

#     if [[ ! -d "$JULIA_DIR" ]]; then
#         echo "Creating Julia directory under tools directory"
#         mkdir -p "$JULIA_DIR"
#         echo "Extracting Julia"
#         tar -xvzf "$JULIA_SRC_NAME" -C "$JULIA_DIR" --strip-components 1
#     fi

#     if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
#         echo "export PATH=\"$JULIA_DIR/bin:\$PATH\"" >>"$HOME/.bashrc"
#         export PATH="$JULIA_DIR/bin:$PATH"
#     fi
# else
#     echo "Julia is already installed. Skip installing it."

# fi

#######################################################################
#                 Install Lua, LuaJIT and luarocks                    #
#######################################################################
LUA_DIR=$HOME/tools/lua
LUA_SRC_NAME=$HOME/packages/lua.tar.gz
LUA_LINK="http://www.lua.org/ftp/lua-5.4.4.tar.gz"
if [[ -z "$(command -v lua)" ]]; then
    echo "Install luarocks"
    if [[ ! -f $LUA_SRC_NAME ]]; then
        echo "Downloading lua and renaming"
        wget $LUA_LINK -O "$LUA_SRC_NAME"
    fi
    
    if [[ ! -d "$LUA_DIR" ]]; then
        echo "Creating lua directory under tools directory"
        mkdir -p "$LUA_DIR"
        echo "Extracting to $HOME/tools/lua directory"
        tar xvf "$LUA_SRC_NAME" -C "$LUA_DIR" --strip-components 1
        cd "$LUA_DIR"
        make all test
    fi
    
    if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
        echo "export PATH=\"$LUA_DIR/src:\$PATH\"" >>"$HOME/.bashrc"
        export PATH="$LUA_DIR/src:$PATH"
    fi
else
    echo "Lua is already installed. Skip installing it."
fi

LUAJIT_DIR=$HOME/tools/luajit
LUAJIT_SRC_NAME=$HOME/packages/luajit.tar.gz
LUAJIT_LINK="https://luajit.org/download/LuaJIT-2.0.5.tar.gz"
if [[ -z "$(command -v luajit)" ]]; then
    echo "Install LuaJIT"
    if [[ ! -f $LUAJIT_SRC_NAME ]]; then
        echo "Downloading LuaJIT and renaming"
        wget $LUAJIT_LINK -O "$LUAJIT_SRC_NAME"
    fi
    
    if [[ ! -d "$LUAJIT_DIR" ]]; then
        echo "Creating LugJIT directory under tools directory"
        mkdir -p "$LUAJIT_DIR"
        echo "Extracting to $HOME/tools/luajit directory"
        tar xvf "$LUAJIT_SRC_NAME" -C "$LUAJIT_DIR" --strip-components 1
        cd "$LUAJIT_DIR"
        make
    fi
    
    if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
        echo "export PATH=\"$LUAJIT_DIR/src:\$PATH\"" >>"$HOME/.bashrc"
        export PATH="$LUAJIT_DIR/src:$PATH"
    fi
else
    echo "LuaJIT is already installed. Skip installing it."
fi

LUAROCKS_DIR=$HOME/tools/luarocks
LUAROCKS_SRC_NAME=$HOME/packages/luarocks.tar.gz
LUAROCKS_LINK="https://luarocks.org/releases/luarocks-3.9.1.tar.gz"
if [[ -z "$(command -v luarocks)" ]]; then
    echo "Install luarocks"
    if [[ ! -f $LUAROCKS_SRC_NAME ]]; then
        echo "Downloading luarocks and renaming"
        wget $LUAROCKS_LINK -O "$LUAROCKS_SRC_NAME"
    fi
    
    if [[ ! -d "$LUAROCKS_DIR" ]]; then
        echo "Creating luarocks directory under tools directory"
        mkdir -p "$LUAROCKS_DIR"
        echo "Extracting to $HOME/tools/luarocks directory"
        tar xvf "$LUAROCKS_SRC_NAME" -C "$LUAROCKS_DIR" --strip-components 1
        cd "$LUAROCKS_DIR"
        ./configure --prefix="$LUAROCKS_DIR" --lua-version=5.4 --with-lua-include="$LUA_DIR/src"
        make
    fi
    
    if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
        echo "export PATH=\"$LUAROCKS_DIR:\$PATH\"" >>"$HOME/.bashrc"
        export PATH="$LUAROCKS_DIR:$PATH"
    fi
else
    echo "luarocks is already installed. Skip installing it."
fi

#######################################################################
#                       Install PHP, Composer                         #
#######################################################################
# NOTE: sudo apt install build-essential autoconf bison re2c libxml2-dev libsqlite3-dev
PHP_DIR=$HOME/tools/php
PHP_LINK="https://github.com/php/php-src.git"
if [[ -z "$(command -v php)" ]]; then
    echo "Install PHP"
    
    if [[ ! -d "$PHP_DIR" ]]; then
        echo "Creating php directory under tools directory"
        mkdir -p "$PHP_DIR"
        echo "git clone php repo"
        git clone --depth=1 "$PHP_LINK" "$PHP_DIR"
        cd "$PHP_DIR"
        ./buildconf
        ./configure --prefix="$PHP_DIR" --with-openssl --with-zlib
        make -j4
        make install
    fi
    
    if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
        echo "export PATH=\"$PHP_DIR/bin:\$PATH\"" >>"$HOME/.bashrc"
        export PATH="$PHP_DIR/bin:$PATH"
    fi
    
    # NOTE: sudo apt install zlib1g zlib1g-dev
    PHP=$PHP_DIR/bin/php
    EXPECTED_CHECKSUM="$($PHP -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$($PHP -r "echo hash_file('sha384', 'composer-setup.php');")"
    
    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
    then
        >&2 echo 'ERROR: Invalid installer checksum'
        rm composer-setup.php
        exit 1
    fi
    
    $PHP composer-setup.php --quiet
    rm composer-setup.php
    mv composer.phar "$PHP_DIR/bin/composer"
    
else
    echo "PHP is already installed. Skip installing it."
fi


