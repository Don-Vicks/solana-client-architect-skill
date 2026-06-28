# Solana Client Architect Skill

An advanced, production-ready AI agent skill for the **Solana AI Kit** that transforms your coding agent into an expert Solana frontend and integration architect.

## 🎯 The Problem It Solves

Bridging the gap between a raw Solana program (IDL) and a robust, production-ready frontend is one of the most common bottlenecks for builders. Furthermore, as the Solana ecosystem transitions to the modern stack, standard AI models consistently hallucinate outdated `v1` code (like `new Transaction()` and `new PublicKey()`).

This skill forces AI agents to write modern, secure, and performant client integrations using **`@solana/kit` (v2)**, **Codama** (formerly Kinobi), and `@tanstack/react-query`.

## ✨ Features (2026 Stack Ready)

- **`@solana/kit` v2 Mastery:** Teaches the agent to use `pipe()` for transaction building, async `getProgramDerivedAddress()`, and modern RPC subscriptions (`signatureNotifications`).
- **Codama & Anchor IDL Support:** Seamlessly integrates with the modern Codama generation pipeline, while providing safe dual-track fallback logic for legacy Anchor v0.31.x support.
- **Progressive Context Loading:** Highly token-efficient architecture. The agent only loads the specific sub-guides it needs (e.g., hooks, UI, or websockets) via the root `SKILL.md` router.
- **Advanced Frontend Patterns:** Includes dedicated, progressively-loaded modules for:
  - **Transaction Simulation:** For precise Compute Unit (CU) estimation before sending.
  - **Priority Fees & Jito MEV:** Built-in guidance for tip accounts and bundle submissions.
  - **WebSockets:** Dual-track patterns for v1 `Connection` and v2 `rpcSubscriptions`.
  - **Token-2022:** Detecting and interacting with Transfer Hook extensions.
  - **Solana Actions & Blinks:** Next.js API route templates and validation.
- **Security First:** A dedicated security module covering input validation, simulation pre-flight checks, RPC security, and strict PDA ownership verifications.

## 📦 Installation

### Option 1: One-Line Quick Install (Recommended)
You can easily install this skill with a single command. It will securely download the necessary files and execute the standard installation script automatically:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Don-Vicks/solana-client-architect-skill/main/quick-install.sh)
```

### Option 2: Manual Clone & Install
If you prefer to manually clone the repository or use custom installation flags, follow these steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Don-Vicks/solana-client-architect-skill.git
   cd solana-client-architect-skill
   ```

2. **Run the installation script:**
   ```bash
   ./install.sh
   ```
   *(For custom agent directory setups, use `./install-custom.sh` instead).*

## 🧠 Skill Structure

This skill strictly follows the optimal standard for the Solana AI Kit:
- `SKILL.md`: The main entry point, phase definitions, and context router.
- `frameworks/`: Core architectural rules for Anchor, Pinocchio, and Quasar.
- `generators/`: Code generation templates for React Hooks, UI components, and Testing (msw, bankrun).
- `advanced/`: Deep dives into specific edge-case topics (Security, Priority Fees, WebSockets, Token Extensions).
- `references/`: Quick lookup tables (Migration v1 to v2, RPC Providers).
- `examples/`: Reference IDLs for the agent to validate its context against.

## 🏆 Superteam Solana AI Kit Bounty

This skill was built and open-sourced for the **Superteam Brasil - Ship useful agent skills** bounty, specifically aiming to solve the critical friction point of frontend IDL integration and accelerating ecosystem adoption of the modern `@solana/kit` v2 standard.
