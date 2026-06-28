# Error Handling Patterns

Robust error handling is critical for Solana applications. You must parse raw on-chain errors into human-readable messages to provide a good user experience.

## 1. Anchor Error Parsing

Anchor provides structured errors. If an Anchor transaction fails, it typically throws an error containing the `AnchorError` details.

```typescript
import { AnchorError, ProgramError } from '@coral-xyz/anchor';

// Inside a mutation's onError callback or try/catch block
try {
  // execute tx...
} catch (err: any) {
  if (err instanceof AnchorError) {
    console.error(`Error Code: ${err.error.errorCode.code}`);
    console.error(`Error Number: ${err.error.errorCode.number}`);
    console.error(`Message: ${err.error.errorMessage}`);
    
    // Map to user-friendly string
    toast.error(`Transaction failed: ${err.error.errorMessage}`);
  } else if (err instanceof ProgramError) {
    // Non-Anchor custom program errors
    toast.error(`Program error: ${err.code}`);
  } else {
    // Parse raw hex codes from logs if classes aren't matched
    const match = err.message?.match(/custom program error: (0x[a-fA-F0-9]+)/);
    if (match) {
        const errorCode = parseInt(match[1], 16);
        toast.error(`Custom error code: ${errorCode}. Check program documentation.`);
    } else {
        toast.error("An unknown error occurred.");
    }
  }
}
```

Pattern: Match the error code against the IDL's `errors` array to provide context.

## 2. `@solana/kit` (v2) Errors

The v2 API uses typed error codes through `SolanaError`.

```typescript
import { isSolanaError, SOLANA_ERROR__JSON_RPC__SERVER_ERROR_SEND_TRANSACTION_PREFLIGHT_FAILURE } from '@solana/kit';

try {
  // send tx...
} catch (err) {
  if (isSolanaError(err, SOLANA_ERROR__JSON_RPC__SERVER_ERROR_SEND_TRANSACTION_PREFLIGHT_FAILURE)) {
    // Extract simulation logs from preflight failure
    console.error("Preflight failed. Logs:", err.context.logs);
    toast.error("Transaction simulation failed. Check console for details.");
  } else {
    // Handle other Solana errors or generic errors
  }
}
```

## 3. Common Transaction Errors

When mapping errors for users, handle these common scenarios:

1. **Insufficient Funds:** The user lacks SOL for fees or rent.
2. **Account Already Initialized:** Trying to initialize a PDA that already exists.
3. **Blockhash Expired:** The transaction took too long to sign (stale nonce).
4. **Compute Budget Exceeded:** The transaction requires more compute units than allocated.
5. **Constraint Violations (Anchor):** `ConstraintSeeds`, `ConstraintMut`, `ConstraintSigner`.

## 4. User-Facing Error Message Mapping

Never expose raw error objects or stack traces to users. Create a mapping function:

```typescript
function getErrorMessage(err: any): string {
    if (err?.message?.includes('Blockhash not found')) {
        return "Transaction timed out. Please try again.";
    }
    if (err?.message?.includes('insufficient lamports')) {
        return "Not enough SOL for transaction fees.";
    }
    // ... map specific program errors
    return "An unexpected error occurred.";
}
```
