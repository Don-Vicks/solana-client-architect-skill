# /build-frontend Command

## Purpose
This command instructs the agent to aggressively scaffold a complete, production-ready Next.js frontend, integrating all essential Solana dependencies, state management libraries, and architectural rules outlined in the `solana-client-architect-skill`.

## Execution Workflow

When the user types `/build-frontend`, execute the following steps exactly as described:

### 1. Framework Scaffolding
Run the Next.js scaffold tool in non-interactive mode.
```bash
npx create-next-app@latest frontend --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --use-npm
```
Navigate into the `frontend` directory: `cd frontend`.

### 2. Dependency Installation
Install the modern Web3 stack, React Query, Zustand, and styling utilities.
```bash
npm install @solana/web3.js@2 @solana/wallet-adapter-react @solana/wallet-adapter-react-ui @solana/wallet-adapter-base @solana/wallet-adapter-wallets
npm install @tanstack/react-query zustand react-hot-toast lucide-react
npm install -D @types/node @typescript-eslint/eslint-plugin
```

### 3. Context Provider Setup
Create a `src/components/providers.tsx` file.
- Implement `ConnectionProvider` and `WalletProvider` from `@solana/wallet-adapter-react`.
- Configure the RPC endpoint using an environment variable (`NEXT_PUBLIC_RPC_URL`) falling back to `devnet`.
- Implement `QueryClientProvider` from `@tanstack/react-query` to wrap the app.
- Ensure `"use client";` is at the very top.

### 4. Layout Integration
Modify `src/app/layout.tsx`:
- Import and wrap the `children` inside the newly created `<Providers>` component.
- Keep `layout.tsx` as a Server Component.

### 5. Verification
Run `npm run build` to verify that the scaffolding compiles without TypeScript or ESLint errors. Output a success message to the user upon completion.
