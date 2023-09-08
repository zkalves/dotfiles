#!/bin/tcsh -f

if($?TMUX_GIT_PROMPT_COMMAND) then
    ( $TMUX_GIT_PROMPT_COMMAND & )
endif
