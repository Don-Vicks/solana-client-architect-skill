# Quasar Framework Setup Rules

[Quasar](https://github.com/blueshift-gg/quasar) is a high-performance, zero-copy, zero-allocation `no_std` Rust framework for Solana programs. It provides Anchor-like ergonomics (`#[program]`, `#[account]`) while achieving extremely low compute unit (CU) overhead, similar to Vanilla/Pinocchio.

When generating a frontend for a Quasar program, recognize that while the Rust backend is heavily optimized, the client-side interaction pattern is similar to Anchor because Quasar generates compatible IDLs.

## 1. IDL & Client Recognition
- **Identification:** Quasar programs export standard JSON IDLs. If the user specifies Quasar, treat frontend initialization similarly to Anchor.
- **Client Libraries:** Quasar IDLs can be consumed by standard TypeScript client generators (including Codama) or the `@coral-xyz/anchor` SDK directly.

## 2. Quasar Provider Setup
Use the Anchor SDK to interact with Quasar on the client side, leveraging the generated IDL.

```typescript
import { Program, AnchorProvider } from "@coral-xyz/anchor";
import { useConnection, useWallet } from "@solana/wallet-adapter-react";
import { useMemo } from "react";
import type { MyQuasarProgram } from "../types/my_quasar_program";
import idl from "../idl/my_quasar_program.json";

export function useQuasarProgram() {
  const { connection } = useConnection();
  const wallet = useWallet();

  const program = useMemo(() => {
    if (!wallet.publicKey) return null;

    const provider = new AnchorProvider(
      connection,
      wallet as any,
      { commitment: 'confirmed' }
    );

    return new Program<MyQuasarProgram>(idl as MyQuasarProgram, provider);
  }, [connection, wallet.publicKey]);

  return program;
}
```

> **Note on v1 Isolation:** Since this uses `@coral-xyz/anchor` (which depends on `@solana/web3.js` v1 internally), all v1 types must remain confined to this provider layer. See [frameworks/anchor.md](anchor.md) §2 for the v1/v2 boundary rules.

## 3. Read-Only Provider
For read-only queries without a connected wallet, create a provider with no signer:
```typescript
const readOnlyProvider = new AnchorProvider(
  connection,
  { publicKey: null, signTransaction: async (tx) => tx, signAllTransactions: async (txs) => txs } as any,
  { commitment: 'confirmed' }
);
const readOnlyProgram = new Program<MyQuasarProgram>(idl as MyQuasarProgram, readOnlyProvider);
```
This allows fetching account data (e.g., for a public dashboard) without requiring the user to connect a wallet.

## 4. Data Deserialization Nuances
- Because Quasar relies on zero-copy access (`bytemuck`) on-chain, data structures are memory-aligned.
- **Padding:** Zero-copy structs may include explicit byte padding. When consuming data via React Query, map only relevant fields and ignore trailing padding bytes.
- **Enums/Unions:** Handle complex nested enums carefully. If the IDL defines C-repr enums, ensure TypeScript interfaces perfectly map to the integer discriminators.

Once the Program context is established, proceed to [generators/hooks.md](../generators/hooks.md) to build React Query hooks.
