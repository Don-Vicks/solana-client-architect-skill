# Solana Client Architect Skill

This skill turns any AI agent into an expert frontend developer for Solana dApps. It bridges the gap between smart contract development and user interface creation by automatically generating production-ready React/Zustand hooks, contexts, and UI components directly from an Interface Definition Language (IDL) file.

## Features
- **Framework Support:** Supports both **Anchor** (via `@coral-xyz/anchor`) and **Pinocchio** (via `@solana/web3.js` and custom parsing).
- **Automated Hooks:** Generates typed React hooks for fetching accounts and executing transactions.
- **UI Scaffolding:** Creates functional, Tailwind-styled React components to test and interact with the contract immediately.
- **Progressive Loading:** Designed for token-efficiency by progressively loading sub-skills based on the framework and task.

## Installation

The skill is composed of standard Markdown files, making it compatible with almost any modern AI coding assistant.

### For Gemini / Antigravity CLI
Run the automated install script:
```bash
chmod +x install.sh
./install.sh
```

### For Cursor / Windsurf IDE
Copy the `skill/` folder into your project's `.cursorrules` or `.windsurf` context directory, or simply @ tag the `SKILL.md` file in your chat.
```bash
cp -r skill/ .cursor/rules/solana-client-architect
```

### For Claude Code / Aider / Cline
You can pass the main entry point to the CLI when asking it to build your frontend:
```bash
claude "Read skill/SKILL.md and build a frontend for target/idl/my_program.json"
```
Or for Aider:
```bash
aider --message "Follow the instructions in skill/SKILL.md to build the UI for my Pinocchio program"
```

## Usage

Once the AI has access to the skill files, simply ask:

> "Use the Solana Client Architect skill to build a frontend for this Anchor IDL located at `target/idl/my_program.json`."
