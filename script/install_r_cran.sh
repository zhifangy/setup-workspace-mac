#!/bin/bash
set -e

# Install R
brew list --cask r &> /dev/null || brew install --cask r

# Add default settings to .Rprofile
RPROFILE_PATH="${HOME}/.Rprofile"
OPTIONS="options(
    save.workspace = \"no\",
    restore.workspace = \"no\"
)
formals(quit)\$save <- formals(q)\$save <- \"no\""
# check if .Rprofile exists
if [ -f "$RPROFILE_PATH" ]; then
    # prompt the user for confirmation to overwrite
    read -p "$RPROFILE_PATH exists. Do you want to overwrite it? (y/n): " choice
    case "$choice" in
        y|Y )
            echo "$OPTIONS" > "$RPROFILE_PATH"
            echo "$RPROFILE_PATH has been overwritten with the default options."
        ;;
        n|N )
            echo "No changes made to $RPROFILE_PATH."
        ;;
        * )
            echo "Invalid input. No changes made."
        ;;
    esac
else
    # if .Rprofile doesn't exist, create it with the default options
    echo "$RPROFILE_PATH created with the default options."
    echo "$OPTIONS" > "$RPROFILE_PATH"
fi
