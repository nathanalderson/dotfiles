# persistenct iex/erl history with 10MB of space
ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_file_bytes 10000000"

# asdf
ASDF_SCRIPT=/opt/asdf-vm/asdf.sh
if [[ -f "$ASDF_SCRIPT" ]]; then
    . $ASDF_SCRIPT
fi

if [[ -f "~/.profile-local" ]]; then
    . ~/.profile-local
fi
