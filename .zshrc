PROFILE_STARTUP=false
if [[ "$PROFILE_STARTUP" == true ]]; then
  zmodload zsh/zprof
fi

# initialize zinit
source ~/.local/share/zinit/zinit.git/zinit.zsh

###
# Prompt theme stuff
###

# enable prompt substitutions and make colors work
setopt promptsubst
autoload colors
colors

# spaceship prompt options
SPACESHIP_PROMPT_TRUNC=0
SPACESHIP_TIME_SHOW=true
SPACESHIP_VI_MODE_SHOW=false
SPACESHIP_PROMPT_SYMBOL=»
SPACESHIP_GIT_UNSTAGED=✘

zinit wait lucid for \
    OMZL::git.zsh \
  atload"set_git_aliases" \
    OMZP::git

PS1="»" # provide a simple prompt till the theme loads

# vscode shell integration must be loaded after the prompt theme
zinit wait'!' lucid for \
    OMZL::prompt_info_functions.zsh \
    'https://github.com/nathanalderson/dotfiles/blob/main/spaceship.zsh-theme'

# This block added by the zinit installer...
# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

###
# Load plugins
###
zinit wait lucid for \
  OMZL::directories.zsh \
  atinit"zicompinit; zicdreplay"  \
    OMZP::colored-man-pages \
  atload"unalias rm mv cp; alias l=ls; alias ll=lsa" \
    OMZP::common-aliases \
  as"completion" \
    OMZP::docker/_docker \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"zicompinit; zicdreplay" blockf \
    OMZL::completion.zsh \
  atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

###
# General options
###

# automatically `cd` to a directory when you type its name (including `..`)
setopt autocd

# History command configuration
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=10000
setopt inc_append_history     # write to HISTFILE immediately
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it

# Autocorrect seems more annoying than helpful...
unsetopt correct_all

setopt extended_glob
setopt interactivecomments

# gnome-terminal and mate-terminal support 256 colors
if [[ (! ("$TERM" =~ '.*256color')) && (("$COLORTERM" == 'gnome-terminal') || ("$COLORTERM" == 'mate-terminal') || ("$COLORTERM" == '')) ]] then
  export TERM=$TERM-256color
fi

# auto-suggestions
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50

###
# Custom aliases and functions
###

alias ls="ls --color=auto"

# aliases for gradle building
alias gw="./(../)#gradlew" # search up the directory tree for gradlew
gbts () { gw test -Dtest.single=$1 ${*:2} }

# alias for activating virtual environment
alias ve="python3 -m virtualenv venv && source venv/bin/activate"
alias ve2="python3 -m virtualenv --python=python2 venv && source venv/bin/activate"
alias ve3="python3 -m virtualenv --python=python3 venv && source venv/bin/activate"
svba () {
    poetry_venv=$(poetry env info --path 2>/dev/null)
    if [ $? -eq 0 ]; then
        source $poetry_venv/bin/activate
    else
        source venv/bin/activate
    fi
}

# alias for serving a directory with python
alias serve2="python -m SimpleHTTPServer"
alias serve="python -m http.server"

# launch nvim in a separate gui.
alias gnv="nvim-qt"
# `vim` launches `nvim` if available
vim() { if command -v nvim &> /dev/null; then env nvim $*; else env vim $*; fi }
# `vvim` always launches vanilla vim
alias vvim="env vim"

# docker-compoose
alias dco='docker-compose'
alias dcup='docker-compose up --build'
alias dcupd='docker-compose up -d --build'
alias dce='docker-compose exec'
alias dcps='docker-compose ps'
alias dcdn='docker-compose down'
alias dcl='docker-compose logs'
alias dclf='docker-compose logs -f'
alias dcr='docker-compose run'

# docker
alias drsa='docker ps -aq | xargs --no-run-if-empty docker rm -f' #"docker stop all"
alias drvc='docker container prune && docker image prune' #"docker very clean"
alias drr='docker run -it --rm' #"docker run"
dre () { docker exec -it ${*:1} }
drip () { docker inspect --format '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@" }

# git
set_git_aliases() {
    alias gb='git branch --sort=-committerdate'
}

# delete the bad host key from the previous ssh command
purgehostkey() {
  cmd=$history[$((HISTCMD-1))]
  lineno=$(eval $cmd 2>&1 | grep -oP 'known_hosts:\K\d+')
  known_hosts=~/.ssh/known_hosts
  host=$(sed -n "${lineno}p" $known_hosts | cut --delimiter=' ' --fields=1)
  sed -i -e "${lineno}d" $known_hosts
  echo "Deleted $host from known_hosts:$lineno 🖥️🔑💥"
  eval $cmd -o StrictHostKeyChecking=accept-new
}

# I can never remember the "xdg" part
alias open='xdg-open'

# allow sudo to use aliases
alias sudo='sudo '

# create a new named tmux session with `tm <name>`
alias tm='tmux new -s '

###
# Other things
###

# Source a local zshrc if it exists
source ~/.zshrc-local

# lazy-load rvm
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  function __init_rvm() {
    unalias rvm
    unset -f __init_rvm
    . "$HOME/.rvm/scripts/rvm"
  }
  alias rvm='__init_rvm && rvm'
fi

# lazy-load nvm
if [ -s "$HOME/.nvm/nvm.sh" ] && [ ! "$(whence -w __init_nvm)" = function ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  declare -a __node_commands=('nvm' 'node' 'npm' 'yarn' 'gulp' 'grunt' 'webpack')
  function __init_nvm() {
    for i in "${__node_commands[@]}"; do unalias $i; done
    . "$NVM_DIR"/nvm.sh
    unset __node_commands
    unset -f __init_nvm
  }
  for i in "${__node_commands[@]}"; do alias $i='__init_nvm && '$i; done
fi

# use vi mode
bindkey -v
export KEYTIMEOUT=2
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^H' backward-kill-word # ctrl-backspace
bindkey "^[[1;5C" forward-word  # ctrl-rightarrow
bindkey "^[[1;5D" backward-word # ctrl-leftarrow
bindkey '^r' history-incremental-search-backward
bindkey '^[1~' end-of-line
bindkey '^[OF' end-of-line
bindkey '^[[F' end-of-line
bindkey '^[4~' beginning-of-line
bindkey '^[OH' beginning-of-line
bindkey '^[[H' beginning-of-line
bindkey '^[[3~' delete-char
# xclip to clipboard
alias -g clip='xclip -selection clipboard'

# open new tabs in same directory. Workaround for https://bugs.launchpad.net/ubuntu-gnome/+bug/1193993
[[ -s "/etc/profile.d/vte.sh" ]] && . /etc/profile.d/vte.sh

# enable command editing in vim
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

if [[ "$PROFILE_STARTUP" == true ]]; then
  zprof
fi

# Set gopath
export GOPATH="$HOME/.godir"
export PATH=$PATH:"$GOPATH/bin"

# mosh
export MOSH_ESCAPE_KEY='~'

# added by travis gem
[ -f /home/nalderso/.travis/travis.sh ] && source /home/nalderso/.travis/travis.sh

# asdf
ASDF_SCRIPT=/opt/asdf-vm/asdf.sh
if [[ -f "$ASDF_SCRIPT" ]]; then
    . $ASDF_SCRIPT
fi
