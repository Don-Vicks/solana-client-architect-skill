# Hook Generation Rules

Once the program provider (Anchor or web3.js) is set up, generate hooks to interact with the smart contract.

## 1. Technology Choice
Default to using `@tanstack/react-query` (React Query) for data fetching and caching. If the user explicitly asks for Zustand or pure React `useState`, adapt accordingly.

## 2. Generating Queries (Fetching Data)
For every `account` definition in the IDL, generate a `useFetch[AccountName]` hook.

**Anchor Example:**
```typescript
import { useQuery } from '@tanstack/react-query';
import { useMyProgram } from './useMyProgram';
import { PublicKey } from '@solana/web3.js';

export function useFetchUserAccount(pubkey: PublicKey | null) {
  const program = useMyProgram();

  return useQuery({
    queryKey: ['userAccount', pubkey?.toString()],
    queryFn: async () => {
      if (!program || !pubkey) return null;
      return await program.account.user.fetch(pubkey);
    },
    enabled: !!program && !!pubkey,
  });
}
```

## 3. Generating Mutations (Transactions)
For every `instruction` in the IDL, generate a `use[InstructionName]` hook.

**Rules for Mutations:**
- Use the Solana wallet adapter `useWallet().sendTransaction` or Anchor's `.rpc()` method.
- Automatically resolve associated token accounts (ATA) or PDAs if the seeds are clear in the IDL.
- Handle errors gracefully, catching `TransactionError` and surfacing the message to the frontend.

Once hooks are generated, proceed to read `generators/ui.md` to build the UI scaffolding.
