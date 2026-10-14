#!/usr/bin/env bash

# tmux-resurrect strategy: restore a vim/nvim session from a central store
# that mirrors the project path, so no Session.vim is written into the
# project itself. install.sh links this in as both vim_central.sh and
# nvim_central.sh, which is where tmux-resurrect looks for it.
#
# The matching :ObsessionHere command in ~/.sivim/init.vim writes to the
# same location.

ORIGINAL_COMMAND="$1"
DIRECTORY="$2"

editor="${ORIGINAL_COMMAND%% *}"
root="${XDG_DATA_HOME:-$HOME/.local/share}/nvim-sessions"
session_file="${root}${DIRECTORY}/Session.vim"

if [ -e "$session_file" ]; then
    echo "$editor -S '$session_file'"
else
    echo "$ORIGINAL_COMMAND"
fi
