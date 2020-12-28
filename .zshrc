PROFILE_STARTUP=false
if [[ "$PROFILE_STARTUP" == true ]]; then
  zmodload zsh/zprof
fi

# initialize zinit
source ~/.zinit/bin/zinit.zsh

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
    OMZP::git \

PS1="»" # provide a simple prompt till the theme loads

zinit wait'!' lucid for \
    OMZL::prompt_info_functions.zsh \
    'https://github.com/nathanalderson/dotfiles/blob/master/spaceship.zsh-theme'

###
# Load plugins
###
zinit wait lucid for \
  OMZL::directories.zsh \
  atinit"zicompinit; zicdreplay"  \
    OMZP::colored-man-pages \
  atload"unalias rm mv cp" \
    OMZP::common-aliases \
  as"completion" \
    OMZP::docker/_docker \
  atload"zicompinit; zicdreplay" blockf \
    OMZL::completion.zsh

###
# General options
###

# automatically `cd` to a directory when you type its name (including `..`)
setopt autocd

# Persist history but don't share it among sessions
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
unsetopt share_history

# Autocorrect seems more annoying than helpful...
unsetopt correct_all

setopt extended_glob
setopt interactivecomments

# gnome-terminal and mate-terminal support 256 colors
if [[ (! ("$TERM" =~ '.*256color')) && (("$COLORTERM" == 'gnome-terminal') || ("$COLORTERM" == 'mate-terminal') || ("$COLORTERM" == '')) ]] then
  export TERM=$TERM-256color
fi

###
# Custom aliases and functions
###

alias ls="ls --color=auto"

# aliases for gradle building
alias gw="./(../)#gradlew" # search up the directory tree for gradlew
gbts () { gw test -Dtest.single=$1 ${*:2} }

# alias for activating virtual environment
alias ve="virtualenv venv && source venv/bin/activate"
alias ve2="virtualenv --python=python2 venv && source venv/bin/activate"
alias ve3="virtualenv --python=python3 venv && source venv/bin/activate"
alias svba="source venv/bin/activate"

# alias for serving a directory with python
alias serve2="python -m SimpleHTTPServer"
alias serve="python -m http.server"

# alias for vpn-ing to Adtran
alias vpn-disconnect='pkill -SIGINT openconnect'
alias vpn-reset='pkill -SIGUSR2 openconnect'

alias home-vpn='sudo wg-quick up wg0'
alias home-vpn-disconnect='sudo wg-quick down wg0'

# launch nvim in a separate gui. must install https://github.com/fmoralesc/neovim-gnome-terminal-wrapper
alias gnv="nvim-wrapper"

# docker-compoose
alias dcupd='docker-compose up -d --build'

# docker
alias drsa='docker ps -aq | xargs --no-run-if-empty docker rm -f' #"docker stop all"
alias drvc='docker container prune && docker image prune' #"docker very clean"
alias drr='docker run -it --rm' #"docker run"
dre () { docker exec -it ${*:1} }
drip () { docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$@" }

# git
diff_pager="diff-so-fancy | less --tabs=4 -RX --pattern '^(Date|added|deleted|modified): '"
alias gd="PAGER=\"$diff_pager\" git diff --color"
alias gdca="PAGER=\"$diff_pager\" git diff --color --cached"

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

###
# Environment variables
###
export P4CONFIG=.p4config
export PATH=$HOME/bin:$PATH
export EDITOR=/usr/bin/vim

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
bindkey '^r' history-incremental-search-backward
bindkey '^[1~' end-of-line
bindkey '^[4~' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^[OH' beginning-of-line
bindkey '^[[3~' delete-char


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

# Add python user bin dir to path
export PATH=$PATH:"$HOME/.local/bin"

# stupid cows
export ANSIBLE_NOCOWS=1

# mosh
export MOSH_ESCAPE_KEY='~'

# added by travis gem
[ -f /home/nalderso/.travis/travis.sh ] && source /home/nalderso/.travis/travis.sh
