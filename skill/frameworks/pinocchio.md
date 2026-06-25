# Pinocchio & Vanilla Framework Setup Rules

When building a frontend for highly optimized, native Solana programs (built with Vanilla Rust or Pinocchio), you must strictly utilize the modern Solana web3 ecosystem. Legacy object-oriented classes (`@solana/web3.js` version 1) are strictly banned in this context.

## 1. Kinobi / Shank Workflows
Pinocchio programs typically utilize Kinobi or Shank to generate their client SDKs.
- **Rule 1:** Always ask the user if they have a Kinobi-generated Umi or web3.js client package available.
- **Rule 2:** If a generated SDK exists, import the typed instructions directly from it. Do not attempt to manually serialize instruction buffers unless the SDK is unavailable.

## 2. Modern Web3 (`@solana/web3.js` version 2)
If you are manually constructing clients based on an IDL without a generated SDK, you must use `@solana/web3.js@2` (or the `@experimental` tag).

### Key Architectural Shifts:
1. **Addresses:** Do not use `new PublicKey()`. Use the `address()` functional wrapper.
   ```typescript
   import { address, Address } from '@solana/web3.js';
   const programId: Address = address('11111111111111111111111111111111');
   ```
2. **Transaction Construction:** Do not use `new Transaction()`. Use `createTransactionMessage()`, append instructions, and compile it for a specific version (V0 with Address Lookup Tables is highly preferred).
   ```typescript
   import { createTransactionMessage, setTransactionMessageFeePayer, appendTransactionMessageInstruction, compileTransactionMessage } from '@solana/web3.js';
   
   // Base message
   let message = createTransactionMessage({ version: 0 });
   message = setTransactionMessageFeePayer(feePayerAddress, message);
   message = appendTransactionMessageInstruction(myInstruction, message);
   
   const compiledMessage = compileTransactionMessage(message);
   ```

## 3. Umi Framework Integration
If the client relies on `@metaplex-foundation/umi`, you must architect a global Umi Context.
- **Provider Pattern:** Wrap the application in a `UmiProvider`.
- **Wallet Adapter Plugin:** Ensure Umi uses the `walletAdapterIdentity()` plugin to sync with the React wallet state.
- **RPC Tuning:** Configure Umi's RPC client with proper retry mechanisms and commitment levels (`confirmed` for reads).

```typescript
// Example Umi setup
import { createUmi } from '@metaplex-foundation/umi-bundle-defaults';
import { walletAdapterIdentity } from '@metaplex-foundation/umi-signer-wallet-adapters';
import { useWallet } from '@solana/wallet-adapter-react';
import { useMemo } from 'react';

export function useUmi() {
  const wallet = useWallet();
  const umi = useMemo(() => {
    const u = createUmi("https://api.devnet.solana.com", { commitment: 'confirmed' });
    if (wallet.publicKey) {
      u.use(walletAdapterIdentity(wallet));
    }
    return u;
  }, [wallet]);

  return umi;
}
```

Once the underlying web3 engine is configured, proceed to [generators/hooks.md](../generators/hooks.md) to build the data-fetching and mutation layers.
