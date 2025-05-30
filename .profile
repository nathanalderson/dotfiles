# persistenct iex/erl history with 10MB of space
ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_file_bytes 10000000"

# asdf
export ASDF_DATA_DIR="$HOME/.asdf"
export PATH="$ASDF_DATA_DIR/shims:$PATH"
