#!/usr/bin/env bash

# tmux-resurrect strategy: restore a vim/nvim session from a central store
# that mirrors the project path, so no Session.vim is written into the
# project itself. This repository owns it because it owns tmux and installs
# the plugin; install.sh links it in as both vim_central.sh and
# nvim_central.sh, which is where tmux-resurrect looks for it.
#
# s:SessionFile() in ~/.sivim/init.vim builds the same path for
# :ObsessionHere. Change one and you must change the other.

ORIGINAL_COMMAND="$1"
DIRECTORY="$2"

editor="${ORIGINAL_COMMAND%% *}"
root="${XDG_DATA_HOME:-$HOME/.local/share}/nvim-sessions"

# Key on the git work tree, not the pane directory: vim's autochdir moves its
# process cwd to the open file's directory, which is what tmux records, so the
# pane directory varies with whatever buffer was last active. The work tree is
# the same from any subdirectory, so vim and this script agree.
key="$(git -C "$DIRECTORY" rev-parse --show-toplevel 2>/dev/null)"
[ -n "$key" ] || key="$DIRECTORY"

session_file="${root}${key}/Session.vim"

if [ -e "$session_file" ]; then
    echo "$editor -S '$session_file'"
else
    echo "$ORIGINAL_COMMAND"
fi
