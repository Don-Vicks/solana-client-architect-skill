#!/bin/bash

# Solana Client Architect Skill - Quick Installer
# This script downloads the repository and runs the local install script

set -e

echo -e "\033[0;36mDownloading Solana Client Architect Skill...\033[0m"
TEMP_DIR=$(mktemp -d)

# Clone into the temporary directory
if ! git clone --depth 1 https://github.com/Don-Vicks/solana-client-architect-skill.git "$TEMP_DIR/skill-repo" > /dev/null 2>&1; then
    echo -e "\033[0;31mFailed to download repository. Please try the manual installation method.\033[0m"
    rm -rf "$TEMP_DIR"
    exit 1
fi

cd "$TEMP_DIR/skill-repo"
chmod +x install.sh

# Run the standard installer in auto-confirm mode
./install.sh -y

# Clean up
cd - > /dev/null
rm -rf "$TEMP_DIR"
