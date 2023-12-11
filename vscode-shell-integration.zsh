# Add paths here to check for vscode shell integration script.
FILE_PATHS=(
   "/opt/visual-studio-code/resources/app/out/vs/workbench/contrib/terminal/browser/media/shellIntegration-rc.zsh"
)

source_if_exists() {
    local file=$1
    if [[ -f $file ]]; then
        . $file
        return 0
    fi
    return 1
}

for path in "${FILE_PATHS[@]}"; do
    if source_if_exists $path; then
        return 0
    fi
done

# If not found, ask vscode where it is (starts nodejs, so a bit slow when starting a terminal)
FALLBACK_PATH=$(code --locate-shell-integration-path zsh)
if source_if_exists $FALLBACK_PATH; then
    return 0
else
    echo "Couldn't find vscode shell integration script"
    return 1
fi

