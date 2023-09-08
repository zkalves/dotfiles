#!/bin/bash

function install_file {
    local src_file=$1
    local dst_link=$2

    if ! [ "$dst_link" -ef "$src_file" ]; then
        if [ -e $dst_link ]; then
            i=0
            while [[ -e $dst_link.bk.$i ]] ; do
                let i++
            done
            dst_file_bk=$dst_link.bk.$i

            cp -r $dst_link $dst_file_bk
            if [ $? -eq 0 ]; then
                rm $dst_link
            fi
        else
            rm -f $dst_link
        fi

        ln -s $src_file $dst_link
    fi
}

libdir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

install_file $libdir/.bashrc        ~/.bashrc
install_file $libdir/.cshrc         ~/.cshrc
install_file $libdir/.gitconfig     ~/.gitconfig
install_file $libdir/.inputrc       ~/.inputrc
install_file $libdir/.screenrc      ~/.screenrc
install_file $libdir/.tmux.conf     ~/.tmux.conf
install_file $libdir/.Xresources    ~/.Xresources
install_file $libdir/.vnc/config    ~/.vnc/config
install_file $libdir/.vnc/xstartup  ~/.vnc/xstartup
install_file $libdir/.vimrc         ~/.vimrc
install_file $libdir/.vim           ~/.vim
install_file $libdir/.vim           ~/.config/nvim
install_file $libdir/.config/xfce4  ~/.config/xfce4
