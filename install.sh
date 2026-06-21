#!/usr/bin/env bash
# install.sh
# Installs the solana-idl-frontend-skill into the global Gemini/Antigravity config directory.

SKILL_NAME="solana-client-architect-skill"
CONFIG_DIR="$HOME/.gemini/config/plugins/solana-skills/skills/$SKILL_NAME"

echo "Installing $SKILL_NAME..."

mkdir -p "$CONFIG_DIR"
cp -r skill/* "$CONFIG_DIR/"

echo "Successfully installed $SKILL_NAME to $CONFIG_DIR!"
echo "Your AI agent can now generate frontends from Solana IDLs."
