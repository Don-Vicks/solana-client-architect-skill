# UI Component Scaffolding Rules

Your final task is to generate React components that utilize the hooks you just created, providing the user with an immediate, visual way to interact with their smart contract.

## 1. Styling Guidelines
- Use **Tailwind CSS** for all styling.
- Create modern, clean, Web3-native interfaces. Use dark mode defaults (e.g., `bg-gray-900 text-white`, `border-gray-800`).
- Use buttons with hover states and disabled states (when transactions are pending or wallets are disconnected).

## 2. Input Validation (Critical)
Before allowing a user to submit a form to the mutation hook, validate the inputs:
- **Public Keys:** If an instruction expects a `PublicKey`, wrap the input parsing in a `try/catch` using `new PublicKey(input)`. If it throws, show a validation error to the user and disable the submit button.
- **Numbers:** If an instruction expects a `u64` or `BN`, ensure the input cannot accept negative numbers (unless signed) and safely convert strings to `BN`.

## 3. Advanced State Management
If an instruction takes a complex struct or enum as an argument, scaffold a dynamic form. For example, if it takes an enum `Role { Admin, User }`, render a `<select>` dropdown.

## 4. Wallet Connection
Always include a check for the user's wallet connection.
```tsx
import { useWallet } from '@solana/wallet-adapter-react';
import { WalletMultiButton } from '@solana/wallet-adapter-react-ui';

export function ComponentWrapper() {
    const { connected } = useWallet();
    if (!connected) {
        return (
            <div className="flex flex-col items-center justify-center p-8 bg-gray-900 rounded-lg border border-gray-800">
                <p className="text-gray-400 mb-4">Please connect your wallet to interact with this program.</p>
                <WalletMultiButton />
            </div>
        );
    }
    // ... render actual component
}
```

## 5. Loading States & Success Links
Use the `isPending` properties from React Query to show loading spinners on the submit buttons. When a transaction succeeds, format the resulting signature into an active hyperlink pointing to `https://explorer.solana.com/tx/[signature]?cluster=devnet`.
