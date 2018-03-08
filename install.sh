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

# skel/ mirrors $HOME too, but its files are seeds: copied once when the
# destination is absent, never overwritten and never symlinked.
# Fontconfig caches by directory mtime and will not notice newly linked
# fonts on its own. Not mkfontdir/mkfontscale: fonts.dir and fonts.scale are
# tracked here and symlinked into place, so those would write back into the
# repository.
function refresh_font_cache {
    local fontdir=$HOME/.local/share/fonts

    if [ -d "$fontdir" ] && command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$fontdir" >/dev/null
        echo "refreshed font cache for $fontdir"
    fi
}

function install_skel {
    local src rel dst

    while IFS= read -r -d '' src; do
        rel=${src#"$libdir/skel/"}
        dst=$HOME/$rel

        if [ -e "$dst" ]; then
            continue
        fi

        mkdir -p "$(dirname "$dst")"
        chmod 700 "$(dirname "$dst")"
        cp "$src" "$dst"
        chmod 600 "$dst"
        echo "seeded $dst - edit it for this machine"
    done < <(find "$libdir/skel" -type f -print0)
}

function install_tmux_plugins {
    local xdg_conf=${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf
    local conf_file=$HOME/.tmux.conf
    local plugins_dir=$HOME/.tmux/plugins

    if [ -f "$xdg_conf" ]; then
        echo "warning: $xdg_conf takes priority over ~/.tmux.conf for both tmux and tpm"
        conf_file=$xdg_conf
        plugins_dir=${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins
    elif [ ! -f "$conf_file" ] && [ -f "$libdir/home/.tmux.conf" ]; then
        conf_file=$libdir/home/.tmux.conf
    fi

    local tpm_dir=$plugins_dir/tpm
    if ! [ -d "$tpm_dir/.git" ]; then
        mkdir -p "$plugins_dir"
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi

    local plugins
    if [ -f "$conf_file" ]; then
        plugins=$(awk '/^[ \t]*set(-option)?[ \t]+-g[ \t]+@plugin/ { gsub(/['\''"]/, ""); print $4 }' "$conf_file")
    fi

    for plugin in $plugins; do
        local repo branch plugin_name target_dir git_url
        IFS='#' read -r repo branch <<< "$plugin"
        plugin_name=$(basename "$repo")
        plugin_name=${plugin_name%.git}
        target_dir="$plugins_dir/$plugin_name"

        if [ -d "$target_dir/.git" ]; then
            continue
        fi

        if [ -d "$target_dir" ]; then
            rm -rf "$target_dir"
        fi

        case "$repo" in
            http://*|https://*|git://*|git@*|ssh://*)
                git_url="$repo"
                ;;
            *)
                git_url="https://github.com/${repo}.git"
                ;;
        esac

        mkdir -p "$plugins_dir"
        if [ -n "$branch" ]; then
            GIT_TERMINAL_PROMPT=0 git clone -b "$branch" --single-branch --recursive "$git_url" "$target_dir"
        else
            GIT_TERMINAL_PROMPT=0 git clone --single-branch --recursive "$git_url" "$target_dir"
        fi
    done

    # tmux-resurrect only loads strategies from inside its own directory, so
    # link ours in after install; a plugin update would otherwise drop it.
    local strategies=$plugins_dir/tmux-resurrect/strategies
    if [ -d "$strategies" ]; then
        ln -sf "$libdir/lib/tmux-resurrect-central.sh" "$strategies/vim_central.sh"
        ln -sf "$libdir/lib/tmux-resurrect-central.sh" "$strategies/nvim_central.sh"
    fi
}

libdir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

case "${1:-all}" in
    links)
        install_links
        install_skel
        refresh_font_cache
        ;;
    plugins)
        install_tmux_plugins
        ;;
    all)
        install_links
        install_skel
        refresh_font_cache
        install_tmux_plugins
        ;;
    *)
        echo "usage: ${BASH_SOURCE[0]} [all|links|plugins]" >&2
        exit 1
        ;;
esac
