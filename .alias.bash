################################################################################
# UTILITIES
################################################################################
# Git commands
#alias git='hub'
alias gadd='git add'
alias gbranch='git branch'
alias gci='git commit'
alias gclone='git clone --recursive'
alias gco='git checkout'
alias gdiff='git diff'
alias gfetch='git fetch'
alias ggr='git gr'
# Pull push commands to avoid unnecesary information on git log
alias gpull='git pull'
#alias gpush='git rebase -i @{u} && git push'
alias gpush='git push'
alias grebase='git rebase'
alias grm='git rm'
alias gsub='git submodule'
alias gst='git status'
alias gstash='git stash'

# SOS commands
alias sadd='soscmd create'
alias sco='soscmd co'
alias sci='soscmd ci'
alias scr='soscmd create'
alias sdis='soscmd discardco'
alias sst='soscmd status'

# Linux commands
alias p='pwd'
alias la='ls -ha'
alias ll='ls -hl'
alias l='ls -hal'
alias h='history'
alias hist='history | tail -20 '
alias grepc='grep --color'
alias grepn='grep -v'
alias bcl='bc -l'
alias duh='du -h --max-depth=1'

alias gtkw='gtkwave waveform.lxt </dev/null &>/dev/null &'

alias vin='nvim'
#alias vinup='nvim.update'
alias vindiff='nvim -d'
alias gv='gvim'
alias ar='acroread'

#License management
#alias lms_lic='lmstat -a -c <PORT_NUMBER>@<SERVER_NAME> -f <LICENSE_NAME>'
#alias rm-lic='lmremove  -c <PORT_NUMBER>@<SERVER_NAME> <LICENSE_NAME> <USER> <HOST> :0.0'
#alias lms-srv='lmstat -a -c <PORT_NUMBER>@<SERVER_NAME>'

# Grid cmds
# alias qsh1='setenv DISPLAY <HOST:0.0>; qsh -q impl'
# alias qsh8='setenv DISPLAY <HOST:0.0>; qsh -q impl -pe smp8'

#Module aliases
alias modav='module avail'
alias modld='module load'

alias rmap='cd ~/projects/rmap'
