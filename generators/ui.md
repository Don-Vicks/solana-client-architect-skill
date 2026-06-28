# UI & Component Generation Rules

Build a responsive, state-aware interface for Solana apps. Web3 interactions are asynchronous and failure-prone — the UI must reflect every stage. Follow the project's existing styling approach (Tailwind, vanilla CSS, CSS modules, etc.) rather than mandating a specific framework.

## 1. Client Components & Hook Wiring

- **`"use client";`** — Required at the top of any file importing `useWallet()`, `useQuery()`, or custom Web3 hooks.
- **Separation of concerns** — Keep components presentational. Pass hook results as props rather than invoking hooks deep in the tree.

## 2. Wallet Connection UX

Always handle the disconnected state explicitly. Never render transaction buttons when no wallet is connected.

```tsx
import { useWalletModal } from '@solana/wallet-adapter-react-ui';

function WalletGate({ children }: { children: React.ReactNode }) {
  const { connected } = useWallet();
  const { setVisible } = useWalletModal();

  if (!connected) {
    return (
      <div className="wallet-gate">
        <p>Connect your wallet to continue.</p>
        <button onClick={() => setVisible(true)}>Connect Wallet</button>
      </div>
    );
  }
  return <>{children}</>;
}
```

## 3. Transaction Lifecycle UI

Surface every stage so the user is never left guessing: **Building → Signing → Confirming → Done / Error**.

```tsx
type TxStage = 'idle' | 'building' | 'signing' | 'confirming' | 'done' | 'error';

function TransactionButton({ onClick, label }: { onClick: () => Promise<string>; label: string }) {
  const [stage, setStage] = useState<TxStage>('idle');

  const handleClick = async () => {
    try {
      setStage('building');
      // ... build tx
      setStage('signing');
      // ... sign tx
      setStage('confirming');
      const sig = await onClick();
      setStage('done');
    } catch {
      setStage('error');
    }
  };

  const labels: Record<TxStage, string> = {
    idle: label,
    building: 'Building…',
    signing: 'Sign in wallet…',
    confirming: 'Confirming…',
    done: '✓ Confirmed',
    error: 'Failed — Retry?',
  };

  return (
    <button onClick={handleClick} disabled={stage !== 'idle' && stage !== 'error'}>
      {labels[stage]}
    </button>
  );
}
```

## 4. Pending & Loading States

- **Button disablement:** Disable the submit button while `isPending` is true.
- **Wallet disablement:** Disable on-chain action buttons when `wallet.connected` is false.
- **Visual feedback:** Show a spinner or status text during async operations.

## 5. Data Formatting Utilities

### BigInt / Lamports

Never render raw `BigInt` into JSX. Use a dedicated formatter:

```typescript
export function formatLamports(lamports: bigint | number, decimals = 9): string {
  const value = typeof lamports === 'bigint' ? lamports : BigInt(lamports);
  const divisor = BigInt(10 ** decimals);
  const whole = value / divisor;
  const fractional = value % divisor;
  const fracStr = fractional.toString().padStart(decimals, '0').slice(0, 4);
  return `${whole}.${fracStr}`;
}

// Usage: <span>{formatLamports(balance)} SOL</span>
```

### Address Truncation & Copy

```tsx
export function AddressDisplay({ address }: { address: string }) {
  const truncated = `${address.slice(0, 4)}…${address.slice(-4)}`;

  const copy = async () => {
    await navigator.clipboard.writeText(address);
    // Show toast or visual confirmation
  };

  return (
    <span title={address} onClick={copy} style={{ cursor: 'pointer' }}>
      {truncated} 📋
    </span>
  );
}
```

## 6. Explorer Link Generation

Generate links to the appropriate Solana explorer based on the current cluster:

```typescript
type Cluster = 'mainnet-beta' | 'devnet' | 'testnet' | 'localnet';

export function getExplorerUrl(
  signature: string,
  cluster: Cluster = 'devnet',
  type: 'tx' | 'address' = 'tx'
): string {
  const base = 'https://explorer.solana.com';
  const clusterParam = cluster === 'mainnet-beta' ? '' : `?cluster=${cluster}`;
  return `${base}/${type}/${signature}${clusterParam}`;
}

// Usage: <a href={getExplorerUrl(sig, 'devnet')} target="_blank">View on Explorer ↗</a>
```

## 7. Design Guidelines

- Follow the project's existing styling approach — do not impose a CSS framework.
- Prefer dark themes with subtle contrast for Web3 apps.
- Add micro-interactions (hover effects, transitions) to interactive elements.
- Use `aria-busy`, `aria-disabled`, and semantic HTML for accessibility.

Once components are built, add tests per [generators/testing.md](testing.md).
