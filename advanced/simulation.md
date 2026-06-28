# Transaction Simulation

Transaction simulation is the process of executing a transaction against the current state of the blockchain without actually committing the state changes or charging fees.

## 1. Why Simulate?

You must ALWAYS simulate transactions before sending them, and ideally before prompting the user to sign:
* **Compute Unit (CU) Estimation:** Discover exactly how many compute units the transaction uses, then set a precise budget.
* **Catch Errors Early:** Identify missing accounts, logic errors, or insufficient funds before the user pays a network fee.
* **Validate State:** Ensure the transaction will have the expected outcome.

## 2. v2 Simulation Pattern (`@solana/kit`)

```typescript
import { getBase64EncodedWireTransaction } from '@solana/kit';

// Assuming compiledTx is your fully built transaction message
const wireTx = getBase64EncodedWireTransaction(compiledTx);

const simResult = await rpc.simulateTransaction(
  wireTx,
  { commitment: 'confirmed', encoding: 'base64' }
).send();

if (simResult.value.err) {
  console.error("Simulation failed:", simResult.value.err);
  console.error("Logs:", simResult.value.logs);
  throw new Error("Transaction simulation failed.");
} else {
  console.log("Compute units consumed:", simResult.value.unitsConsumed);
  // Safe to proceed
}
```

## 3. Simulation in Mutation Flow

The ideal production flow for a mutation hook:

1. **Build** the transaction WITHOUT a strict Compute Unit limit.
2. **Simulate** the transaction.
3. If error: **Abort** and show a user-friendly message.
4. If success: **Rebuild** the transaction adding a `SetComputeUnitLimit` instruction where `limit = simResult.value.unitsConsumed * 1.15` (15% buffer).
5. **Sign** the transaction via the wallet adapter.
6. **Send** and confirm.
