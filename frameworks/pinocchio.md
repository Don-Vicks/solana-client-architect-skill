# Pinocchio & Vanilla Framework Setup Rules

When building a frontend for optimized native Solana programs (Vanilla Rust or Pinocchio), strictly use the modern `@solana/kit` (v2) ecosystem. Legacy v1 classes (`PublicKey`, `Transaction`, `Keypair`) are banned in this context.

## 1. Codama / Shank Workflows
Pinocchio programs typically use **Codama** (formerly Kinobi) or Shank to generate client SDKs.

- **Rule 1:** Always ask the user if they have a Codama-generated client package (`@codama/renderers-js` output) or a Umi client available.
- **Rule 2:** If a generated SDK exists, import the typed instruction builders and account decoders directly. Do not manually serialize instruction buffers unless the SDK is unavailable.
- **Rule 3:** Codama-generated clients targeting `@solana/kit` export instruction helpers that return `IInstruction` objects compatible with `appendTransactionMessageInstruction()`.

## 2. RPC Setup (`@solana/kit`)
Create typed RPC clients for both HTTP and WebSocket connections:
```typescript
import { createSolanaRpc, createSolanaRpcSubscriptions } from '@solana/kit';

const rpc = createSolanaRpc('https://api.devnet.solana.com');
const rpcSubscriptions = createSolanaRpcSubscriptions('wss://api.devnet.solana.com');
```

## 3. Addresses
Never use `new PublicKey()`. Use the `address()` helper for compile-time type branding:
```typescript
import { address, type Address } from '@solana/kit';
const programId: Address = address('11111111111111111111111111111111');
```

## 4. Transaction Building with `pipe()`
Use the functional `pipe()` pattern from `@solana/functional` for clean transaction composition:
```typescript
import { pipe } from '@solana/functional';
import {
  createTransactionMessage,
  setTransactionMessageFeePayer,
  setTransactionMessageLifetimeUsingBlockhash,
  appendTransactionMessageInstruction,
  compileTransaction,
} from '@solana/kit';

const { value: latestBlockhash } = await rpc.getLatestBlockhash().send();

const transaction = pipe(
  createTransactionMessage({ version: 0 }),
  (tx) => setTransactionMessageFeePayer(feePayerAddress, tx),
  (tx) => setTransactionMessageLifetimeUsingBlockhash(latestBlockhash, tx),
  (tx) => appendTransactionMessageInstruction(myInstruction, tx),
);

const compiledTx = compileTransaction(transaction);
```

## 5. Signing & Sending
Use `signAndSendTransactionMessageWithSigners` for the standard wallet-adapter flow:
```typescript
import { signAndSendTransactionMessageWithSigners } from '@solana/kit';

const signature = await signAndSendTransactionMessageWithSigners(transaction);
```
The transaction message must have signers attached (e.g., via wallet adapter integration) before calling this helper.

## 6. Async PDA Derivation
PDA derivation in `@solana/kit` is **asynchronous**. Never call it synchronously:
```typescript
import { getProgramDerivedAddress, getAddressEncoder } from '@solana/kit';

const encoder = getAddressEncoder();
const [pda, bump] = await getProgramDerivedAddress({
  programAddress: programId,
  seeds: [
    new TextEncoder().encode('my-seed'),
    encoder.encode(userAddress),
  ],
});
```

## 7. Umi Integration (Metaplex Programs)
If the client relies on `@metaplex-foundation/umi` (e.g., for Metaplex Token Metadata, Bubblegum), architect a global Umi Context:
```typescript
import { createUmi } from '@metaplex-foundation/umi-bundle-defaults';
import { walletAdapterIdentity } from '@metaplex-foundation/umi-signer-wallet-adapters';
import { useWallet } from '@solana/wallet-adapter-react';
import { useMemo } from 'react';

export function useUmi() {
  const wallet = useWallet();
  return useMemo(() => {
    const umi = createUmi('https://api.devnet.solana.com', { commitment: 'confirmed' });
    if (wallet.publicKey) {
      umi.use(walletAdapterIdentity(wallet));
    }
    return umi;
  }, [wallet.publicKey]);
}
```

Once the web3 engine is configured, proceed to [generators/hooks.md](../generators/hooks.md) to build data-fetching and mutation layers.
