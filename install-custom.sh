#!/bin/bash

# Solana Client Architect Skill Installer for Claude Code
# Usage: ./install-custom.sh [--project | --path <path>]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHITECT_SKILL_NAME="solana-client-architect"
CORE_SKILL_NAME="solana-dev"
SOURCE_DIR="$SCRIPT_DIR/skill"

# Default paths
PERSONAL_SKILLS_DIR="$HOME/.claude/skills"
GEMINI_SKILLS_DIR="$HOME/.gemini/config/skills"
PROJECT_SKILLS_DIR=".claude/skills"

# Installation targets (set during prompts)
INSTALL_BASE=""
ARCHITECT_INSTALL_PATH=""
CORE_INSTALL_PATH=""
CORE_SKILL_FOUND=""
CORE_SKILL_LOCATION=""

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
    echo -e "${MAGENTA}║${NC}   ${WHITE}Solana Client Architect Skill for Claude Code${NC}              ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}                                                               ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_help() {
    echo "Solana Client Architect Skill Installer"
    echo ""
    echo "Usage: ./install-custom.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --project        Install to current project (.claude/skills/)"
    echo "  --gemini         Install to Gemini/Antigravity (~/.gemini/config/skills/)"
    echo "  --path PATH      Install to custom path"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "The installer will:"
    echo "  1. Check if solana-dev-skill is already installed"
    echo "  2. If not found, offer to install it"
    echo "  3. Install solana-client-architect skill addon"
    echo ""
}

find_core_skill() {
    # Check common locations for solana-dev-skill
    local locations=(
        "$PERSONAL_SKILLS_DIR/$CORE_SKILL_NAME"
        "$GEMINI_SKILLS_DIR/$CORE_SKILL_NAME"
        "$PROJECT_SKILLS_DIR/$CORE_SKILL_NAME"
        "$HOME/.claude/$CORE_SKILL_NAME"
    )

    for loc in "${locations[@]}"; do
        if [ -d "$loc" ] && [ -f "$loc/SKILL.md" ]; then
            CORE_SKILL_FOUND="true"
            CORE_SKILL_LOCATION="$loc"
            return 0
        fi
    done

    CORE_SKILL_FOUND="false"
    return 1
}

prompt_install_location() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}  ${WHITE}Select Installation Location${NC}                               ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${WHITE}[1]${NC} ${GREEN}Claude Personal skills${NC} (~/.claude/skills/)"
    echo -e "      ${YELLOW}Available to all Claude projects${NC}"
    echo ""
    echo -e "  ${WHITE}[2]${NC} ${GREEN}Gemini Personal skills${NC} (~/.gemini/config/skills/)"
    echo -e "      ${YELLOW}Available to Antigravity / Gemini${NC}"
    echo ""
    echo -e "  ${WHITE}[3]${NC} ${GREEN}Current project${NC} (./.claude/skills/)"
    echo -e "      ${YELLOW}Only for this project${NC}"
    echo ""
    echo -e "  ${WHITE}[4]${NC} ${RED}Cancel${NC}"
    echo ""

    read -p "Select option [1-4]: " choice

    case $choice in
        1)
            INSTALL_BASE="$PERSONAL_SKILLS_DIR"
            ;;
        2)
            INSTALL_BASE="$GEMINI_SKILLS_DIR"
            ;;
        3)
            INSTALL_BASE="$PROJECT_SKILLS_DIR"
            ;;
        4)
            echo -e "${YELLOW}Installation cancelled${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Installation cancelled${NC}"
            exit 1
            ;;
    esac

    ARCHITECT_INSTALL_PATH="$INSTALL_BASE/$ARCHITECT_SKILL_NAME"
    CORE_INSTALL_PATH="$INSTALL_BASE/$CORE_SKILL_NAME"
}

prompt_install_core_skill() {
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}  ${WHITE}Core Skill Required${NC}                                        ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${YELLOW}solana-dev-skill${NC} was not found."
    echo -e "  The architect skill depends on it for:"
    echo -e "    ${BLUE}•${NC} Anchor/Pinocchio program development context"
    echo -e "    ${BLUE}•${NC} Security checklists"
    echo ""
    echo -e "  ${WHITE}[1]${NC} ${GREEN}Install both${NC} (solana-dev + solana-client-architect)"
    echo -e "  ${WHITE}[2]${NC} ${YELLOW}Install architect skill only${NC} (I'll install core separately)"
    echo -e "  ${WHITE}[3]${NC} ${RED}Cancel${NC}"
    echo ""

    read -p "Select option [1-3]: " choice

    case $choice in
        1)
            install_core_skill
            ;;
        2)
            echo -e "${YELLOW}Warning:${NC} Architect skill will have broken references to core skill"
            echo -e "Install solana-dev-skill to: ${BLUE}$CORE_INSTALL_PATH${NC}"
            ;;
        3)
            echo -e "${YELLOW}Installation cancelled${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Installation cancelled${NC}"
            exit 1
            ;;
    esac
}

install_core_skill() {
    echo ""
    echo -e "${CYAN}━━━ Installing Core Solana Dev Skill ━━━${NC}"

    mkdir -p "$CORE_INSTALL_PATH"

    echo -e "Cloning from ${BLUE}github.com/solana-foundation/solana-dev-skill${NC}..."

    local temp_dir=$(mktemp -d)
    if git clone --depth 1 https://github.com/solana-foundation/solana-dev-skill.git "$temp_dir" 2>/dev/null; then
        cp -r "$temp_dir/skill/"* "$CORE_INSTALL_PATH/"
        rm -rf "$temp_dir"
        echo -e "${GREEN}✓${NC} Installed solana-dev-skill to: $CORE_INSTALL_PATH"
        CORE_SKILL_FOUND="true"
        CORE_SKILL_LOCATION="$CORE_INSTALL_PATH"
    else
        rm -rf "$temp_dir"
        echo -e "${RED}Error:${NC} Failed to clone solana-dev-skill"
        echo -e "${YELLOW}You can install it manually:${NC}"
        echo -e "  git clone https://github.com/solana-foundation/solana-dev-skill"
        echo -e "  cp -r solana-dev-skill/skill/* $CORE_INSTALL_PATH/"
        return 1
    fi
}

install_architect_skill() {
    echo ""
    echo -e "${CYAN}━━━ Installing Solana Client Architect Skill ━━━${NC}"

    if [ ! -d "$SOURCE_DIR" ]; then
        echo -e "${RED}Error:${NC} Source directory '$SOURCE_DIR' not found"
        exit 1
    fi

    if [ -d "$ARCHITECT_INSTALL_PATH" ]; then
        echo -e "${YELLOW}Warning:${NC} '$ARCHITECT_INSTALL_PATH' already exists"
        read -p "Overwrite? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Skipping architect skill installation${NC}"
            return 0
        fi
        rm -rf "$ARCHITECT_INSTALL_PATH"
    fi

    mkdir -p "$ARCHITECT_INSTALL_PATH"

    for item in "$SOURCE_DIR"/*; do
        local basename=$(basename "$item")
        if [ "$basename" != "solana-dev-skill" ]; then
            cp -r "$item" "$ARCHITECT_INSTALL_PATH/"
        fi
    done

    echo -e "${GREEN}✓${NC} Installed solana-client-architect-skill to: $ARCHITECT_INSTALL_PATH"
}

install_claude_md() {
    local claude_md_source="$SCRIPT_DIR/CLAUDE.md"

    echo ""
    echo -e "${CYAN}━━━ CLAUDE.md Configuration ━━━${NC}"
    echo ""
    echo -e "  ${WHITE}[1]${NC} Copy to ${GREEN}current directory${NC} (.)"
    echo -e "  ${WHITE}[2]${NC} Copy to ${GREEN}home .claude${NC} (~/.claude/)"
    echo -e "  ${WHITE}[3]${NC} ${YELLOW}Skip${NC} CLAUDE.md installation"
    echo ""

    read -p "Select option [1-3]: " claude_choice

    case $claude_choice in
        1)
            cp "$claude_md_source" "./CLAUDE.md"
            echo -e "${GREEN}✓${NC} Copied CLAUDE.md to current directory"
            ;;
        2)
            mkdir -p "$HOME/.claude"
            cp "$claude_md_source" "$HOME/.claude/CLAUDE.md"
            echo -e "${GREEN}✓${NC} Copied CLAUDE.md to ~/.claude/"
            ;;
        3)
            echo -e "${YELLOW}Skipping CLAUDE.md installation${NC}"
            ;;
        *)
            echo -e "${YELLOW}Invalid option, skipping CLAUDE.md${NC}"
            ;;
    esac
}

print_success() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}   ${WHITE}Installation Complete!${NC}                                     ${GREEN}║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [ -d "$ARCHITECT_INSTALL_PATH" ]; then
        echo -e "${WHITE}Architect Skill:${NC} $ARCHITECT_INSTALL_PATH"
    fi

    if [ "$CORE_SKILL_FOUND" = "true" ]; then
        echo -e "${WHITE}Core Skill:${NC} $CORE_SKILL_LOCATION"
    fi

    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --project)
            INSTALL_BASE="$PROJECT_SKILLS_DIR"
            shift
            ;;
        --gemini)
            INSTALL_BASE="$GEMINI_SKILLS_DIR"
            shift
            ;;
        --path)
            INSTALL_BASE="$2"
            shift 2
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

# Main execution
print_banner

if [ -z "$INSTALL_BASE" ]; then
    prompt_install_location
else
    ARCHITECT_INSTALL_PATH="$INSTALL_BASE/$ARCHITECT_SKILL_NAME"
    CORE_INSTALL_PATH="$INSTALL_BASE/$CORE_SKILL_NAME"
fi

if find_core_skill; then
    echo -e "${GREEN}✓${NC} Found solana-dev-skill at: ${BLUE}$CORE_SKILL_LOCATION${NC}"
else
    echo -e "${YELLOW}✗${NC} solana-dev-skill not found"
    prompt_install_core_skill
fi

install_architect_skill
install_claude_md
print_success
