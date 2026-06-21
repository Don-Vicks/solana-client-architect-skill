# Anchor Framework Rules

When the user provides an Anchor IDL, follow these steps to set up the client connection.

## 1. Dependencies
Ensure the user's project has the following dependencies. If not, instruct them to install them:
```bash
npm install @coral-xyz/anchor @solana/web3.js @solana/wallet-adapter-react
```

## 2. Program Provider Context
Generate a React Context that initializes the Anchor `Program` instance.

**Requirements:**
- Use `useConnection` and `useWallet` from `@solana/wallet-adapter-react`.
- Instantiate an Anchor `Provider` using `new AnchorProvider(connection, wallet, AnchorProvider.defaultOptions())`.
- Instantiate the `Program` using `new Program(IDL, programId, provider)`.
- Export a custom hook (e.g., `useMyProgram`) that returns the program instance.

**Example Snippet:**
```typescript
import { Program, AnchorProvider, setProvider } from "@coral-xyz/anchor";
import { useConnection, useWallet } from "@solana/wallet-adapter-react";
import { useMemo } from "react";
import idl from "../idl/my_program.json";

export function useMyProgram() {
  const { connection } = useConnection();
  const wallet = useWallet();

  const program = useMemo(() => {
    if (!wallet.publicKey) return null;
    const provider = new AnchorProvider(connection, wallet as any, AnchorProvider.defaultOptions());
    return new Program(idl as any, provider);
  }, [connection, wallet]);

  return program;
}
```

Once the provider is generated, proceed to read `generators/hooks.md`.
