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
                rm -rf "$dst_link"
            fi
        else
            rm -f $dst_link
        fi

        ln -s $src_file $dst_link
    fi
}

function install_links {
    install_file $libdir/.bash_aliases  ~/.bash_aliases
    install_file $libdir/.cshrc         ~/.cshrc
    install_file $libdir/.gitconfig     ~/.gitconfig
    install_file $libdir/.inputrc       ~/.inputrc
    install_file $libdir/.tmux.conf     ~/.tmux.conf
    install_file $libdir/.tmux          ~/.tmux
    install_file $libdir/.Xresources    ~/.Xresources
    install_file $libdir/.vnc/config    ~/.vnc/config
    install_file $libdir/.vnc/xstartup  ~/.vnc/xstartup
    install_file $libdir/.config/xfce4  ~/.config/xfce4
}

function install_gitconfig_local {
    local target=~/.gitconfig.local

    if ! [ -e $target ]; then
        cp $libdir/gitconfig.local.example $target
        echo "created $target - uncomment [user] and set name/email before committing"
    fi
}

function install_tmux_plugins {
    local tpm_dir=$libdir/.tmux/plugins/tpm
    local xdg_conf=${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf

    if [ -f $xdg_conf ]; then
        echo "warning: $xdg_conf takes priority over ~/.tmux.conf for both tmux and tpm"
    fi

    if [ -f $libdir/.gitmodules ]; then
        git -C $libdir submodule update --init --recursive
    elif ! [ -d $tpm_dir/.git ]; then
        git clone https://github.com/tmux-plugins/tpm $tpm_dir
    fi

    if [ -x $tpm_dir/bin/install_plugins ]; then
        tmux start-server
        tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins/"
        $tpm_dir/bin/install_plugins
    fi
}

libdir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

case "${1:-all}" in
    links)
        install_links
        install_gitconfig_local
        ;;
    plugins)
        install_tmux_plugins
        ;;
    all)
        install_links
        install_gitconfig_local
        install_tmux_plugins
        ;;
    *)
        echo "usage: ${BASH_SOURCE[0]} [all|links|plugins]" >&2
        exit 1
        ;;
esac
