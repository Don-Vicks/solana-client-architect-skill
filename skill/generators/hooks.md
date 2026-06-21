# Hook Generation Rules

Once the program provider (Anchor or web3.js) is set up, generate hooks to interact with the smart contract.

## 1. Technology Choice
Default to using `@tanstack/react-query` (React Query) for data fetching and caching. If the user explicitly asks for Zustand or pure React `useState`, adapt accordingly.

## 2. Generating Queries (Fetching Data)
For every `account` definition in the IDL, generate a `useFetch[AccountName]` hook.

**Requirements:**
- Ensure proper dependency arrays and `enabled` flags so queries don't run without a connected wallet or valid program.

## 3. Generating Mutations (Transactions)
For every `instruction` in the IDL, generate a `use[InstructionName]` hook.

**Robustness Requirements for Mutations:**
- **Simulate First:** Instruct the user to use `.simulate()` (if using Anchor) or send with `skipPreflight: false` to catch errors before the transaction hits the chain.
- **Error Handling & Toasts:** Import a toast library like `react-hot-toast` or `sonner`. Wrap the RPC call in a `try/catch`. 
  - On success: `toast.success('Transaction Successful! View on Explorer: ...')`
  - On error: Catch `TransactionError` or `SendTransactionError` and extract the underlying program error code. `toast.error(parsedErrorMsg)`
- **Cache Invalidation:** Use React Query's `queryClient.invalidateQueries({ queryKey: [...] })` in the `onSuccess` callback of the mutation. This ensures the UI instantly reflects the new state (e.g., updating a balance or fetching the newly created account).

Once hooks are generated, proceed to read `generators/ui.md` to build the UI scaffolding.
