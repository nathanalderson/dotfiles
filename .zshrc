# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="spaceship"
SPACESHIP_PROMPT_TRUNC=0
SPACESHIP_TIME_SHOW=true
SPACESHIP_VI_MODE_SHOW=false
SPACESHIP_PROMPT_SYMBOL=»
SPACESHIP_GIT_UNSTAGED=✘

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias rs="python manage.py runserver 0.0.0.0:8000"
alias cgi="python manage.py runfcgi host=127.0.0.1 port=8080 --settings=settings --pythonpath=adtran_tests"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git django virtualenv virtualenvwrapper common-aliases dircycle dirhistory supervisor gradle)

source $ZSH/oh-my-zsh.sh

# remove aliases I don't want
unalias rm
unalias cp
unalias mv

# gnome-terminal and mate-terminal support 256 colors
if [[ (! ("$TERM" =~ '.*256color')) && (("$COLORTERM" == 'gnome-terminal') || ("$COLORTERM" == 'mate-terminal') || ("$COLORTERM" == '')) ]] then
  export TERM=$TERM-256color
fi

# Sharing history among sessions is annoying to me
unsetopt share_history

# Autocorrect seems more annoying than helpful...
unsetopt correct_all

setopt extended_glob
setopt interactivecomments

# aliases for gradle building
alias gw="./(../)#gradlew" # search up the directory tree for gradlew
gbts () { gw test -Dtest.single=$1 ${*:2} }

# alias for activating virtual environment
alias ve="virtualenv venv && source venv/bin/activate"
alias ve2="virtualenv --python=python2 venv && source venv/bin/activate"
alias ve3="virtualenv --python=python3 venv && source venv/bin/activate"
alias svba="source venv/bin/activate"

# alias for serving a directory with python
alias serve="python -m SimpleHTTPServer"

# alias for vpn-ing to Adtran
alias vpn="openconnect --juniper vpn.adtran.com"

# launch nvim in a separate gui. must install https://github.com/fmoralesc/neovim-gnome-terminal-wrapper
alias gnv="nvim-wrapper"

source ~/.zshrc-local

# allow comments in interactive shells
setopt interactivecomments

# Some environment variables
export P4CONFIG=.p4config
PATH=$HOME/bin:$PATH

# Setup virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/dev
source $(which virtualenvwrapper.sh)

export NVM_DIR="/home/nalderso/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# use vi mode
bindkey -v
export KEYTIMEOUT=2
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward
bindkey '^[OF' end-of-line
bindkey '^[OH' beginning-of-line
bindkey '^[[3~' delete-char


# allow sudo to use aliases
alias sudo='sudo '

# open new tabs in same directory. Workaround for https://bugs.launchpad.net/ubuntu-gnome/+bug/1193993
. /etc/profile.d/vte.sh

# enable command editing in vim
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
