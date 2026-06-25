# TypeScript Rules for Solana Frontends

TypeScript is critical for maintaining safety when bridging untyped, decentralized environments with the frontend UI. Adhere strictly to the following professional guidelines.

## 1. Compiler Configuration
- **Strict Mode:** `"strict": true` MUST be enabled in `tsconfig.json`. This encompasses `noImplicitAny`, `strictNullChecks`, and `strictFunctionTypes`.
- **ESNext:** Target modern ESNext environments to leverage native `BigInt` support and modern asynchronous features.

## 2. Typing Solana Ecosystems
- **Explicit Imports:** When utilizing the modern `@solana/web3.js` version 2, ensure you are importing the `Address` type for public keys.
  ```typescript
  import { Address, address } from '@solana/web3.js';
  // Correct
  const programId: Address = address("11111111111111111111111111111111");
  ```
- **Avoid Legacy Types:** Do not type variables as `PublicKey` unless forced by a legacy dependency (like an older version of Anchor).

## 3. Handling Numbers and Precision
Solana programs utilize 64-bit integers (`u64`) which exceed JavaScript's safe integer limit (`Number.MAX_SAFE_INTEGER`).
- **BigInt Native:** Always type incoming token balances and lamports as `BigInt`. 
- **Formatting:** Create utility functions to format `BigInt` into human-readable decimals securely, without triggering precision loss.
  ```typescript
  export const formatLamports = (lamports: bigint, decimals: number = 9): string => {
      // Implementation avoiding floating point math on large numbers
  };
  ```

## 4. Nullability and Wallet State
- The `useWallet()` hook frequently returns `null` or `undefined` for `publicKey` or `signTransaction` when the user is not connected.
- **Guard Clauses:** Always implement early returns and guard clauses. Never use the non-null assertion operator (`!`) blindly.
  ```typescript
  if (!wallet || !wallet.publicKey) {
      throw new Error("Wallet not connected");
  }
  ```

## 5. Interface Segregation
- Separate on-chain data types from UI data types.
- Example: If an IDL returns a struct with `Uint8Array` strings, create a mapping function that converts it to a standard `string` inside a distinct UI Interface before the component consumes it.

## 6. Prohibited Practices
- **`any` is banned.** Use `unknown` if the type is truly dynamic, and use type guards to narrow it.
- **`@ts-ignore` is banned.** Fix the underlying typing issue or use `@ts-expect-error` with a detailed comment explaining the upstream library failure.
