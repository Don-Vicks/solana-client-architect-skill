#!/bin/bash

# Solana Client Architect Skill - Standard Installer
# Installs with recommended defaults. For custom options, use ./install-custom.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skill"

# Standard defaults
SKILLS_DIR="$HOME/.claude/skills"
ARCHITECT_SKILL_PATH="$SKILLS_DIR/solana-client-architect-skill"
CORE_SKILL_PATH="$SKILLS_DIR/solana-dev"
CLAUDE_MD_PATH="$HOME/.claude/CLAUDE.md"

print_banner() {
    echo ""
    echo -e "${MAGENTA}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC}                                                               ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${CYAN}███████╗${GREEN} ██████╗ ${YELLOW}██╗      ${RED}    ${BLUE}██████╗  █████╗ ███╗   ███╗███████╗${NC}  ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${CYAN}██╔════╝${GREEN}██╔═══██╗${YELLOW}██║      ${RED}    ${BLUE}██╔════╝ ██╔══██╗████╗ ████║██╔════╝${NC}  ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${CYAN}███████╗${GREEN}██║   ██║${YELLOW}██║      ${RED}    ${BLUE}██║  ███╗███████║██╔████╔██║█████╗${NC}    ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${CYAN}╚════██║${GREEN}██║   ██║${YELLOW}██║      ${RED}    ${BLUE}██║   ██║██╔══██║██║╚██╔╝██║██╔══╝${NC}    ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${CYAN}███████║${GREEN}╚██████╔╝${YELLOW}███████╗${RED}    ${BLUE}╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗${NC}  ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${CYAN}╚══════╝${GREEN} ╚═════╝ ${YELLOW}╚══════╝${RED}    ${BLUE} ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝${NC}  ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}                                                               ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${WHITE}Solana Client Architect Skill${NC}                              ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}                                                               ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_help() {
    echo "Solana Client Architect Skill - Standard Installer"
    echo ""
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Installs with recommended defaults:"
    echo "  - Location: ~/.claude/skills/"
    echo "  - Installs both solana-dev and solana-client-architect skills"
    echo "  - Copies CLAUDE.md to ~/.claude/"
    echo ""
    echo "Options:"
    echo "  -y, --yes      Skip confirmation prompt"
    echo "  -h, --help     Show this help"
    echo ""
    echo "For custom installation options, use: ./install-custom.sh"
    echo ""
}

# Parse arguments
SKIP_CONFIRM=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            SKIP_CONFIRM=true
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Main
print_banner

echo -e "${WHITE}Standard Installation${NC}"
echo ""
echo -e "This will install:"
echo -e "  ${BLUE}•${NC} solana-client-architect  → ${CYAN}$ARCHITECT_SKILL_PATH${NC}"
echo -e "  ${BLUE}•${NC} solana-dev-skill         → ${CYAN}$CORE_SKILL_PATH${NC}"
echo -e "  ${BLUE}•${NC} CLAUDE.md                → ${CYAN}$CLAUDE_MD_PATH${NC}"
echo ""

if [ "$SKIP_CONFIRM" = false ]; then
    read -p "Proceed with installation? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Installation cancelled${NC}"
        echo -e "For custom options, run: ${CYAN}./install-custom.sh${NC}"
        exit 0
    fi
fi

echo ""

# Create directories
mkdir -p "$SKILLS_DIR"
mkdir -p "$HOME/.claude"

# Install core skill (solana-dev)
echo -e "${CYAN}[1/3]${NC} Installing solana-dev-skill..."

if [ -d "$CORE_SKILL_PATH" ]; then
    echo -e "  ${YELLOW}→${NC} Removing existing installation"
    rm -rf "$CORE_SKILL_PATH"
fi

temp_dir=$(mktemp -d)
if git clone --depth 1 --quiet https://github.com/solana-foundation/solana-dev-skill.git "$temp_dir" 2>/dev/null; then
    cp -r "$temp_dir/skill" "$CORE_SKILL_PATH"
    rm -rf "$temp_dir"
    echo -e "  ${GREEN}✓${NC} Installed to $CORE_SKILL_PATH"
else
    rm -rf "$temp_dir"
    echo -e "  ${RED}✗${NC} Failed to clone solana-dev-skill"
    echo -e "  ${YELLOW}→${NC} Install manually: https://github.com/solana-foundation/solana-dev-skill"
fi

# Install architect skill
echo -e "${CYAN}[2/3]${NC} Installing solana-client-architect-skill..."

if [ -d "$ARCHITECT_SKILL_PATH" ]; then
    echo -e "  ${YELLOW}→${NC} Removing existing installation"
    rm -rf "$ARCHITECT_SKILL_PATH"
fi

mkdir -p "$ARCHITECT_SKILL_PATH"
for item in "$SOURCE_DIR"/*; do
    basename=$(basename "$item")
    if [ "$basename" != "solana-dev-skill" ]; then
        cp -r "$item" "$ARCHITECT_SKILL_PATH/"
    fi
done
echo -e "  ${GREEN}✓${NC} Installed to $ARCHITECT_SKILL_PATH"

# Install CLAUDE.md
echo -e "${CYAN}[3/3]${NC} Installing CLAUDE.md..."

if [ -f "$CLAUDE_MD_PATH" ]; then
    echo -e "  ${YELLOW}→${NC} Backing up existing CLAUDE.md"
    cp "$CLAUDE_MD_PATH" "$CLAUDE_MD_PATH.backup"
fi

cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_MD_PATH"
echo -e "  ${GREEN}✓${NC} Installed to $CLAUDE_MD_PATH"

# Install to Gemini / Antigravity
GEMINI_SKILLS_DIR="$HOME/.gemini/config/skills"
GEMINI_ARCHITECT_PATH="$GEMINI_SKILLS_DIR/solana-client-architect-skill"

echo -e "${CYAN}[4/4]${NC} Installing for Gemini (Antigravity)..."
mkdir -p "$GEMINI_SKILLS_DIR"
if [ -d "$GEMINI_ARCHITECT_PATH" ]; then
    rm -rf "$GEMINI_ARCHITECT_PATH"
fi
cp -r "$ARCHITECT_SKILL_PATH" "$GEMINI_ARCHITECT_PATH"
echo -e "  ${GREEN}✓${NC} Installed to $GEMINI_ARCHITECT_PATH"

# Done
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}Installation Complete!${NC}                                       ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${WHITE}Installed:${NC}"
echo -e "  ${GREEN}✓${NC} solana-dev-skill          ${CYAN}$CORE_SKILL_PATH${NC}"
echo -e "  ${GREEN}✓${NC} solana-client-architect   ${CYAN}$ARCHITECT_SKILL_PATH${NC}"
echo -e "  ${GREEN}✓${NC} Gemini Architect Skill    ${CYAN}$GEMINI_ARCHITECT_PATH${NC}"
echo -e "  ${GREEN}✓${NC} CLAUDE.md                 ${CYAN}$CLAUDE_MD_PATH${NC}"
echo ""
echo -e "${CYAN}Try asking Claude:${NC}"
echo -e "  ${BLUE}•${NC} \"Build a frontend for this Anchor IDL located at target/idl/my_program.json\""
echo -e "  ${BLUE}•${NC} \"Generate React Query hooks for my Pinocchio program\""
echo ""
