set path = (~/usr/local/bin_ov $path ~/usr/local/bin ~/usr/bin)

source ~/.dotfiles/.cshrc.libs
source ~/.dotfiles/.alias.tcsh
#source /asic/utils/scripts/cshrc.general > /dev/null

if ( $?DISPLAY ) then
    if ($DISPLAY != ":0.0" && $DISPLAY != ":0" && `hostname` !~ *"dalek"* ) then
        setenv DISPLAY `hostname`:`echo $DISPLAY | cut -d ':' -f2`
    endif
endif

#set prompt_ending='$'
# set prompt_template="[%{\033[34m%}%n@%m %{\033[1m%}%~]%{\033[0m%} "
# set _GIT_PROMPT_FULL = 0
# set _GIT_PROMPT_ENABLED = 0
# set _GIT_TMUX_ENABLED = 0
# if ( -f /asic/utils/git-kit/cshrc.git) then
#   source /asic/utils/git-kit/cshrc.git /asic/utils/git-kit
# else
#   set promt = "$prompt_template$prompt_ending"
# endif

#if (! $?SGE_BINARY_PATH) then
if ($?prompt) then
    stty -ixon
endif
umask 022

#Follow symlinks properly with cs
set symlinks="expand"
