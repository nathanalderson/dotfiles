# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="muse"

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
plugins=(git django virtualenv virtualenvwrapper common-aliases dircycle dirhistory pip supervisor)

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

# alias for gradle building
gbts () { gradle test -Dtest.single=$1 ${*:2} }

# alias for activating virtual environment
alias svba="source venv/bin/activate"

source ~/.zshrc-local

# allow comments in interactive shells
setopt interactivecomments

# Some environment variables
export P4CONFIG=.p4config
PATH=$HOME/bin:$PATH

# Setup virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/dev
source /usr/local/bin/virtualenvwrapper.sh

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

