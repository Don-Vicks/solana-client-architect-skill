# UI Component Scaffolding Rules

Your final task is to generate React components that utilize the hooks you just created, providing the user with an immediate, visual way to interact with their smart contract.

## 1. Styling Guidelines
- Use **Tailwind CSS** for all styling.
- Create modern, clean, Web3-native interfaces. Use dark mode defaults (e.g., `bg-gray-900 text-white`, `border-gray-800`).
- Use buttons with hover states and disabled states (when transactions are pending or wallets are disconnected).

## 2. Wallet Connection
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

## 3. Form Inputs
For instructions that take arguments (e.g., `amount: u64`, `name: string`), generate controlled form inputs in React.
- Ensure proper type conversion (e.g., strings to `BN` or BigInt for `u64`).

## 4. Loading States
Use the `isLoading` or `isPending` properties from React Query to show loading spinners or text while transactions are confirming on-chain.
