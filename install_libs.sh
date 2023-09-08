#!/bin/bash

# Script for installing tmux on systems where you don't have root access.
# tmux will be installed in $HOME/local/bin
# It's assumed that wget and a C/C++ compiler are installed

# exit on error
set -e

# create out directories

USR_HOME=$HOME/usr/local
SRC_TMP=$HOME/work/src/tmp
mkdir -p ${USR_HOME} ${SRC_TMP}
cd ${SRC_TMP}

function install_package () {
    src_name=${2##*/}
    #debug="echo "
    if [[ $1 == *"git"* ]]; then
        pkg_name=$(basename "$2" .git)
        echo "Installing library $pkg_name"
        eval "${debug}git clone --recurse-submodules" $2
        cd $pkg_name
    else
        pkg_name=`tar -tf $src_name | head -1 | cut -f1 -d "/"`
        echo "Installing library $pkg_name"
        eval "${debug}wget" $2
        if [[ $src_name == *".tar.xz" ]]; then
            extract_cmd="tar xf"
        else
            extract_cmd="tar xvzf"
        fi
        eval ${debug}$extract_cmd $src_name
        cd $pkg_name
    fi
    if [[ $pkg_name == "neovim" ]]; then
        eval ${debug}"make CMAKE_EXTRA_FLAGS=\"-DCMAKE_INSTALL_PREFIX=$HOME/usr/local\""
    else
        eval ${debug}"./configure --prefix=$USR_HOME" $3
        eval ${debug"make"
    fi
    eval ${debug}"make install"
    cd ..
}

install_package wget https://ftp.gnu.org/gnu/help2man/help2man-1.47.8.tar.xz
install_package wget https://ftp.gnu.org/gnu/automake/automake-1.16.1.tar.gz
install_package wget https://ftp.gnu.org/gnu/ncurses/ncurses-6.1.tar.gz
install_package wget https://hisham.hm/htop/releases/2.2.0/htop-2.2.0.tar.gz
install_package wget https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz "--disable-shared"
install_package git  https://github.com/tmux/tmux.git
install_package git  https://github.com/neovim/neovim.git
