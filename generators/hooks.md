# React Query Hooks Generation Rules

Generate dedicated custom hooks with `@tanstack/react-query` for all on-chain data. Components must never interact with the blockchain directly. Two tracks exist depending on the project's client library.

## Query Key Factory (Shared)

Define a single query key factory per program. All hooks reference it for consistent cache management.

```typescript
// keys.ts
export const programKeys = {
  all: ['my-program'] as const,
  accounts: (type: string) => [...programKeys.all, type] as const,
  account: (type: string, addr: string) =>
    [...programKeys.accounts(type), addr] as const,
};
```

---

## Track A: Anchor (v1) Hooks

Use with `@coral-xyz/anchor` and `@solana/web3.js` v1. Anchor v0.31.x still uses v1 internally.

### Data Fetching

```typescript
export function useFetchProfile(userPubkey: PublicKey | null) {
  const program = useMyProgram();

  return useQuery({
    queryKey: programKeys.account('profile', userPubkey?.toString() ?? ''),
    queryFn: async () => {
      if (!program || !userPubkey) throw new Error('Missing deps');
      try {
        return await program.account.userProfile.fetch(userPubkey);
      } catch (err: any) {
        if (err.message?.includes('Account does not exist')) return null;
        throw err;
      }
    },
    enabled: !!program && !!userPubkey,
    staleTime: 5 * 60_000,
    retry: 2,
    refetchOnWindowFocus: false,
  });
}
```

> **Key rules:** Use `toString()` (not `toBase58()`) for query keys. Always set `enabled`, `retry`, and `refetchOnWindowFocus`.

### Mutations

```typescript
export function useCreateProfile() {
  const program = useMyProgram();
  const { publicKey } = useWallet();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ username }: { username: string }) => {
      if (!program || !publicKey) throw new Error('Wallet not connected');

      const [profilePda] = PublicKey.findProgramAddressSync(
        [Buffer.from('profile'), publicKey.toBuffer()],
        program.programId
      );

      const sig = await program.methods
        .initializeProfile(username)
        .accounts({ profile: profilePda, user: publicKey })
        .rpc();

      // Blockhash-based confirmation
      const bh = await program.provider.connection.getLatestBlockhash();
      await program.provider.connection.confirmTransaction(
        { signature: sig, ...bh },
        'confirmed'
      );
      return sig;
    },
    onSettled: () => {
      // Invalidate on both success and error to keep cache fresh
      queryClient.invalidateQueries({ queryKey: programKeys.accounts('profile') });
    },
    onError: (error: any) => {
      // Parse Anchor errors for human-readable messages
      const anchorErr = error?.error?.errorCode?.code;
      const msg = anchorErr
        ? `Program error: ${anchorErr} — ${error.error.errorMessage}`
        : error.message;
      console.error('Transaction failed:', msg);
    },
  });
}
```

---

## Track B: @solana/kit (v2) Hooks

Use with `@solana/kit` (formerly `@solana/web3.js` v2) and Codama-generated clients (formerly Kinobi).

### Data Fetching

```typescript
import { getProfileDecoder } from './codama-generated'; // Codama decoder

export function useFetchProfile(address: Address | null) {
  const rpc = useRpc();

  return useQuery({
    queryKey: programKeys.account('profile', address ?? ''),
    queryFn: async () => {
      if (!rpc || !address) throw new Error('Missing deps');
      const account = await rpc.getAccountInfo(address, { encoding: 'base64' }).send();
      if (!account.value) return null;
      return getProfileDecoder().decode(account.value.data);
    },
    enabled: !!rpc && !!address,
    retry: 2,
    refetchOnWindowFocus: false,
  });
}
```

### Mutations

```typescript
import { pipe } from '@solana/functional';
import { signAndSendTransactionMessageWithSigners } from '@solana/kit';

export function useCreateProfile() {
  const rpc = useRpc();
  const rpcSubscriptions = useRpcSubscriptions();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ username }: { username: string }) => {
      // PDA derivation is async in v2
      const profilePda = await getProgramDerivedAddress({
        programAddress: PROGRAM_ADDRESS,
        seeds: [string({ size: 'variable' }).encode('profile'), getSignerAddress()],
      });

      const sig = await pipe(
        createTransactionMessage({ version: 0 }),
        (m) => setTransactionMessageFeePayerSigner(feePayer, m),
        (m) => setTransactionMessageLifetimeUsingBlockhash(blockhash, m),
        (m) => appendTransactionMessageInstruction(createProfileIx(username, profilePda), m),
        (m) => signAndSendTransactionMessageWithSigners(m)
      );

      // Confirm via RPC subscription
      const abortController = new AbortController();
      await rpcSubscriptions
        .signatureNotifications(sig, { commitment: 'confirmed' })
        .subscribe({ abortSignal: abortController.signal });

      return sig;
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: programKeys.accounts('profile') });
    },
  });
}
```

---

## Shared Patterns

- **Batch invalidation:** Use `programKeys.all` to invalidate every query for a program at once.
- **Prefetching:** Call `queryClient.prefetchQuery(...)` in parent components or `onMouseEnter` to preload data.
- **`onSettled` over `onSuccess`:** Prefer `onSettled` for cache invalidation so stale data is cleared even on errors.

Once hooks are defined, proceed to [generators/ui.md](ui.md) to wire them into components.
