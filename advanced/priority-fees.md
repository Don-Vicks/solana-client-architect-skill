# Priority Fees & Compute Budget Management

In the modern Solana environment, executing transactions without dynamically setting Compute Units (CU) and Priority Fees often leads to dropped or unconfirmed transactions due to network congestion.

## 1. Setting Compute Budgets

Never rely on the default compute budget (200,000 CU) for complex transactions. If the transaction exceeds the budget, it will fail. If the budget is significantly higher than required, the user overpays for priority fees.

### Web3.js v2 (`@solana/kit`) Implementation

Use instructions from `@solana-program/compute-budget` and append them to your V0 transaction message.

```typescript
import { pipe } from '@solana/functional';
import {
    createTransactionMessage,
    appendTransactionMessageInstruction,
} from '@solana/kit';
import { 
    getSetComputeUnitLimitInstruction, 
    getSetComputeUnitPriceInstruction 
} from '@solana-program/compute-budget';

// 1. Set the compute unit limit (simulation-based estimation is recommended)
const cuLimitIx = getSetComputeUnitLimitInstruction({ units: 120_000 });

// 2. Set the dynamic priority fee (price per compute unit)
const cuPriceIx = getSetComputeUnitPriceInstruction({ microLamports: 10_000n });

// 3. Append to V0 Message
let message = pipe(
    createTransactionMessage({ version: 0 }),
    m => appendTransactionMessageInstruction(cuLimitIx, m),
    m => appendTransactionMessageInstruction(cuPriceIx, m)
);
```

## 2. Dynamic Priority Fees

Hardcoding microLamports is dangerous. During high congestion, the hardcoded fee may be too low. During low congestion, the user wastes SOL.

### Implementation Rule
1. Prior to building the transaction, invoke the RPC's `getRecentPrioritizationFees` API.
2. Filter the fees specifically for the program accounts you are interacting with (local fee market).
3. Calculate a competitive percentile (e.g., 75th percentile) from the recent blocks.

```typescript
// v2 pattern for dynamic fee estimation
export async function fetchOptimalPriorityFee(rpc: Rpc, accounts: Address[]) {
    const response = await rpc.getRecentPrioritizationFees(accounts).send();
    const fees = response.value;
    
    if (fees.length === 0) return 1000n; // fallback base fee
    const sorted = fees.sort((a, b) => Number(a.prioritizationFee - b.prioritizationFee));
    const index = Math.floor(sorted.length * 0.75);
    return sorted[index].prioritizationFee;
}
```

## 3. Simulation-Based Compute Unit Estimation

Do not guess compute units. Simulate the transaction to find the exact usage, then add a buffer.

```typescript
// 1. Build transaction WITHOUT CU limit
// 2. Simulate: const sim = await rpc.simulateTransaction(tx).send();
// 3. Read compute units: const unitsConsumed = sim.value.unitsConsumed;
// 4. Add 10-20% buffer, rebuild with getSetComputeUnitLimitInstruction
```

## 4. Jito MEV Integration (Advanced)

For applications handling high-value swaps, liquidations, or time-sensitive operations, use Jito Bundles to prevent front-running and ensure reliable landing.

### Integration Patterns:
1. **Tip Accounts:** Jito maintains 8 rotating tip account addresses. You must randomly select one and add a SOL transfer instruction to it at the end of your transaction.
2. **Endpoint:** Swap the default RPC URL for a Jito Block Engine endpoint (e.g., `https://mainnet.block-engine.jito.wtf/api/v1/bundles`).
3. **Bundle Submission:** Submit transactions via `jito-ts` or direct HTTP POST requests to the bundle endpoint.

```typescript
// Pattern for adding Jito tip instruction
import { getTransferInstruction } from '@solana-program/system';

const jitoTipAccount = address('...'); // Select randomly from Jito's rotating list
const tipAmount = 100_000n; // Dynamic based on urgency

const tipIx = getTransferInstruction({
    source: feePayerAddress,
    destination: jitoTipAccount,
    amount: tipAmount,
});

// Append tipIx to your transaction message
```
