# Solana Client Architect Skill

This skill turns any AI agent into an expert frontend developer for Solana dApps. It bridges the gap between smart contract development and user interface creation by automatically generating production-ready React/Zustand hooks, contexts, and UI components directly from an Interface Definition Language (IDL) file.

## Features
- **Framework Support:** Supports both **Anchor** (via `@coral-xyz/anchor`) and **Pinocchio** (via `@solana/web3.js` and custom parsing).
- **Automated Hooks:** Generates typed React hooks for fetching accounts and executing transactions.
- **UI Scaffolding:** Creates functional, Tailwind-styled React components to test and interact with the contract immediately.
- **Progressive Loading:** Designed for token-efficiency by progressively loading sub-skills based on the framework and task.

## Installation

Run the `install.sh` script to install the skill into your Gemini/Antigravity config directory:

```bash
chmod +x install.sh
./install.sh
```

## Usage

Once installed, simply ask your AI agent:

> "Build a frontend for this Anchor IDL located at `target/idl/my_program.json`."

Or for Pinocchio:

> "Generate the web3.js client and React hooks for this Pinocchio program based on this Kinobi IDL."
