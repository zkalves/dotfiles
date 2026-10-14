#!/bin/bash

# Everything under home/ mirrors $HOME and is symlinked into place.
# Anything an existing path would shadow is backed up to <name>.bk.<n> first.

function install_file {
    local src_file=$1
    local dst_link=$2

    if [ "$dst_link" -ef "$src_file" ]; then
        return
    fi

    if [ -e "$dst_link" ] || [ -L "$dst_link" ]; then
        local i=0
        while [ -e "$dst_link.bk.$i" ]; do
            i=$((i + 1))
        done
        cp -r "$dst_link" "$dst_link.bk.$i" && rm -rf "$dst_link"
    fi

    ln -s "$src_file" "$dst_link"
}

function install_links {
    local src rel dst

    while IFS= read -r -d '' src; do
        rel=${src#"$libdir/home/"}
        dst=$HOME/$rel
        mkdir -p "$(dirname "$dst")"
        install_file "$src" "$dst"
    done < <(find "$libdir/home" -type f -print0)
}

function install_gitconfig_local {
    local target=$HOME/.gitconfig.local

    if ! [ -e "$target" ]; then
        cp "$libdir/templates/gitconfig.local.example" "$target"
        echo "created $target - uncomment [user] and set name/email before committing"
    fi
}

function install_tmux_plugins {
    local tpm_dir=$HOME/.tmux/plugins/tpm
    local xdg_conf=${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf

    if [ -f "$xdg_conf" ]; then
        echo "warning: $xdg_conf takes priority over ~/.tmux.conf for both tmux and tpm"
    fi

    if ! [ -d "$tpm_dir/.git" ]; then
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi

    if [ -x "$tpm_dir/bin/install_plugins" ]; then
        tmux start-server
        tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins/"
        "$tpm_dir/bin/install_plugins"
    fi
}

libdir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

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
