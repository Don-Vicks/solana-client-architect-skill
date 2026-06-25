# Solana Client Architect Skill

This skill turns any AI agent into an expert frontend developer for Solana dApps. It bridges the gap between smart contract development and user interface creation by automatically generating production-ready React hooks, contexts, and modern UI components directly from an Interface Definition Language (IDL) file.

## Features
- **Framework Support:** Supports both **Anchor** (via `@coral-xyz/anchor`) and **Pinocchio** (via modern `@solana/web3.js` version 2 and Kinobi).
- **Explicit Modern Libraries:** explicitly instructs agents to use **version 2** of `@solana/web3.js` (`@solana/web3.js@2`), moving away from legacy version 1 object-oriented classes like `PublicKey`.
- **Automated Hooks:** Generates typed React Query hooks for fetching accounts and executing transactions robustly.
- **UI Scaffolding:** Creates functional, Tailwind-styled React components to test and interact with the contract immediately.

## Installation

The skill is composed of standard Markdown files, making it compatible with almost any modern AI coding assistant. We provide a CLI tool to seamlessly install it into your IDE or Agent's context directory.

### Quick Install via NPX

Run the command and specify your target environment:

```bash
# Install for Cursor IDE
npx solana-client-architect-skill cursor

# Install for Windsurf IDE
npx solana-client-architect-skill windsurf

# Install globally for Antigravity/Gemini
npx solana-client-architect-skill antigravity

# Install locally to a generic `.agent-skills` folder
npx solana-client-architect-skill local
```

### Manual Installation

#### For Claude Code / Aider / Cline
You can pass the main entry point to the CLI when asking it to build your frontend:
```bash
claude "Read skill/SKILL.md and build a frontend for target/idl/my_program.json"
```
Or for Aider:
```bash
aider --message "Follow the instructions in skill/SKILL.md to build the UI for my Pinocchio program"
```

#### For GitHub Copilot Chat
Open the `SKILL.md` file in your editor, and in the chat window, type `@workspace` or reference the file directly:
```text
@workspace Read skill/SKILL.md and generate the frontend hooks for target/idl/program.json
```

#### For Roo Code (VSCode Extension)
Roo Code can directly read files. Instruct it to start with the entry point:
```text
Please read skill/SKILL.md and follow its instructions to build my Pinocchio frontend.
```

#### For ChatGPT / Claude Web UIs
If you are using the web interfaces, simply upload the `idl.json` along with the relevant markdown files from the `skill/` folder (e.g., `SKILL.md`, `anchor.md`, `hooks.md`) and ask:
> "Read the attached skill instructions and use them to generate a frontend for the attached IDL."

## Usage

Once the AI has access to the skill files, simply ask:

> "Use the Solana Client Architect skill to build a frontend for this Anchor IDL located at `target/idl/my_program.json`."
