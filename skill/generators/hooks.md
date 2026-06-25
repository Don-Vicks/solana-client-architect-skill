# React Query Hooks Generation Rules

React components should never interact with the blockchain directly. You must generate dedicated, strongly-typed custom hooks utilizing `@tanstack/react-query` to manage fetching, caching, and mutating on-chain data.

## 1. Data Fetching Hooks (`useQuery`)
Whenever reading data from a program account (e.g., fetching a User Profile, fetching a list of Vaults), generate a custom hook utilizing `useQuery`.

### Strict Requirements:
- **Query Keys:** Query keys MUST be strictly structured arrays. They must include the program identifier, the account type, and the specific public key being fetched. This ensures accurate cache invalidation later.
  `queryKey: ['my-program', 'user-profile', userPubkey?.toBase58()]`
- **Enable Flags:** Always use the `enabled` configuration option to prevent queries from running if dependent variables (like the `program` instance or `wallet.publicKey`) are null.
  `enabled: !!program && !!userPubkey`
- **Graceful Nulls:** If the account does not exist (throws an "Account does not exist" error), catch the error and return `null`. Do not crash the application.

```typescript
// Example Data Fetching Hook
export function useFetchUserProfile(userPubkey: PublicKey | null) {
  const program = useMyProgram();

  return useQuery({
    queryKey: ['my-program', 'user-profile', userPubkey?.toBase58()],
    queryFn: async () => {
      if (!program || !userPubkey) throw new Error("Missing dependencies");
      try {
        return await program.account.userProfile.fetch(userPubkey);
      } catch (err) {
        // Handle uninitialized accounts gracefully
        if (err.message.includes("Account does not exist")) return null;
        throw err;
      }
    },
    enabled: !!program && !!userPubkey,
    staleTime: 1000 * 60 * 5, // 5 minutes
  });
}
```

## 2. Transaction Hooks (`useMutation`)
Whenever writing data to the blockchain (executing instructions), generate a custom hook utilizing `useMutation`.

### Strict Requirements:
- **Transaction Flow:** Build the transaction -> Send the transaction -> Confirm the transaction.
- **Error Handling:** Wrap the execution in a `try/catch`. Use logging tools or standard console outputs. Parse the `TransactionError` to provide a human-readable string to the UI.
- **Cache Invalidation:** The most critical step. Upon `onSuccess`, you MUST explicitly invalidate the React Query caches associated with the accounts modified by the transaction. If a user deposits funds, the vault balance query must be invalidated so the UI updates instantly.

```typescript
// Example Mutation Hook
export function useCreateProfile() {
  const program = useMyProgram();
  const queryClient = useQueryClient();
  const { publicKey } = useWallet();

  return useMutation({
    mutationFn: async ({ username }: { username: string }) => {
      if (!program || !publicKey) throw new Error("Wallet not connected");

      // Generate PDAs or required accounts
      const [profilePda] = PublicKey.findProgramAddressSync(
        [Buffer.from("profile"), publicKey.toBuffer()],
        program.programId
      );

      // Execute transaction (Anchor Example)
      const txSignature = await program.methods
        .initializeProfile(username)
        .accounts({
          profile: profilePda,
          user: publicKey,
          systemProgram: SystemProgram.programId,
        })
        .rpc();

      // Wait for confirmation
      const latestBlockhash = await program.provider.connection.getLatestBlockhash();
      await program.provider.connection.confirmTransaction({
        signature: txSignature,
        ...latestBlockhash,
      }, 'confirmed');

      return txSignature;
    },
    onSuccess: (signature) => {
      // CRITICAL: Invalidate the fetch query to trigger a UI refresh
      queryClient.invalidateQueries({
        queryKey: ['my-program', 'user-profile', publicKey?.toBase58()]
      });
      console.log("Success! TX:", signature);
    },
    onError: (error) => {
      console.error("Transaction failed:", error);
    }
  });
}
```

Once your hooks are robustly defined, proceed to [generators/ui.md](ui.md) to wire them into the React components.
