# Add ~/bin and ~/.local/bin to PATH
export PATH="$HOME/.local/bin":"$HOME/bin":"$HOME/.pub-cache/bin":$PATH:"$HOME/Android/Sdk/tools/bin":"$HOME/Android/Sdk/cmdline-tools/latest/bin/"

# Use nvim for editor
export EDITOR=/usr/bin/nvim

# Stupid cows
export ANSIBLE_NOCOWS=1

# Clipmenu config
export CM_OWN_CLIPBOARD=1
export CM_LAUNCHER=rofi
export CM_IGNORE_WINDOW=.*keepass.*

# iex history
export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_file_bytes 10000000"
# build Elixir with Docs
export KERL_BUILD_DOCS=yes
