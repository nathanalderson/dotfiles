# Add ~/bin and ~/.local/bin to PATH
export PATH="$HOME/.local/bin":"$HOME/bin":$PATH

# Use nvim for editor
export EDITOR=/usr/bin/nvim

# Stupid cows
export ANSIBLE_NOCOWS=1

# Clipmenu config
export CM_OWN_CLIPBOARD=1
export CM_LAUNCHER=rofi
export CM_IGNORE_WINDOW=.*keepass.*
