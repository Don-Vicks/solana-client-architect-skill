# Pinocchio Framework Rules

Pinocchio is a zero-dependency, highly optimized Solana program library. Programs written in Pinocchio do not natively export an Anchor-compatible `idl.json`. 

When working with Pinocchio:

## 1. Identify the Client Strategy
Pinocchio projects typically use **Kinobi** (via Shank or a custom parser) to generate clients, or they rely on pure `@solana/web3.js` vanilla transactions.

Ask the user:
> "Do you have a Kinobi-generated client/Umi IDL, or should I generate vanilla `@solana/web3.js` transaction instructions?"

## 2. Vanilla web3.js Strategy
If the user wants vanilla web3.js, you must manually construct `TransactionInstruction` objects based on the account order and instruction discriminators they provide.

**Example Snippet:**
```typescript
import { TransactionInstruction, PublicKey, SystemProgram } from "@solana/web3.js";

export const createMyInstruction = (
  programId: PublicKey,
  signer: PublicKey,
  targetAccount: PublicKey
) => {
  return new TransactionInstruction({
    programId,
    keys: [
      { pubkey: signer, isSigner: true, isWritable: true },
      { pubkey: targetAccount, isSigner: false, isWritable: true },
      { pubkey: SystemProgram.programId, isSigner: false, isWritable: false }
    ],
    // The instruction discriminator/data for Pinocchio
    data: Buffer.from([0x01]), 
  });
}
```

## 3. Umi/Kinobi Strategy
If the user provides Kinobi output, use the `@metaplex-foundation/umi` ecosystem.
Ensure the dependencies are installed:
```bash
npm install @metaplex-foundation/umi @metaplex-foundation/umi-bundle-defaults
```
Create a context for the Umi instance instead of an Anchor provider.

Once the client connection/functions are established, proceed to read `generators/hooks.md`.
