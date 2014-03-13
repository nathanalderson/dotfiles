export TERM=xterm-256color

PATH=$HOME/bin:$PATH

if [ -r .bashrc-local ]; then
    source .bashrc-local
fi
