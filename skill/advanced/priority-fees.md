# Priority Fees & Compute Budget Management

In the modern Solana environment, executing transactions without dynamically setting Compute Units (CU) and Priority Fees often leads to dropped or unconfirmed transactions due to network congestion.

## 1. Setting Compute Budgets

Never rely on the default compute budget (200,000 CU) for complex transactions. If the transaction exceeds the budget, it will fail. If the budget is significantly higher than required, the user overpays for priority fees.

### Web3.js v2 Implementation
Always prepend the `ComputeBudgetProgram` instructions to your transaction message.

```typescript
import { getComputeBudgetInstructions } from '@solana-program/compute-budget';

// 1. Simulate the transaction to find optimal Compute Units (or hardcode an empirically known value)
const optimalComputeUnits = 120000;

// 2. Set the compute unit limit
const { setComputeUnitLimit, setComputeUnitPrice } = getComputeBudgetInstructions({
    units: optimalComputeUnits,
    microLamports: 10000, // Dynamic priority fee per compute unit
});

// 3. Append to V0 Message
let message = createTransactionMessage({ version: 0 });
message = appendTransactionMessageInstruction(setComputeUnitLimit, message);
message = appendTransactionMessageInstruction(setComputeUnitPrice, message);
// ... append actual program instructions
```

## 2. Dynamic Priority Fees

Hardcoding microLamports is dangerous. During high congestion, the hardcoded fee may be too low. During low congestion, the user wastes SOL.

### Implementation Rule
1. Prior to building the transaction, invoke the RPC's `getRecentPrioritizationFees` API.
2. Filter the fees specifically for the program accounts you are interacting with (local fee market).
3. Calculate a competitive percentile (e.g., 75th percentile) from the recent blocks.

```typescript
// Pseudo-code for dynamic fee estimation
export async function fetchOptimalPriorityFee(connection: Connection, accounts: PublicKey[]) {
    const fees = await connection.getRecentPrioritizationFees({
        lockedWritableAccounts: accounts
    });
    
    // Sort and calculate the 75th percentile fee
    if (fees.length === 0) return 1000; // fallback base fee
    const sorted = fees.sort((a, b) => a.prioritizationFee - b.prioritizationFee);
    const index = Math.floor(sorted.length * 0.75);
    return sorted[index].prioritizationFee;
}
```

## 3. Jito MEV Integration (Advanced)
For applications handling high-value swaps or liquidations, instruct the `web3-specialist` agent to implement Jito Bundles to prevent front-running. This requires swapping the default RPC URL for a Jito Block Engine endpoint and appending a standard Jito Tip instruction.
