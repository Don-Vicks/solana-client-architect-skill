# Token 2022 / Token Extensions

The Token-2022 program (`TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb`) is a superset of the original Token program, offering native extensions.

## 1. Detecting the Token Program

Always dynamically check the account owner to determine which program to use. Do not hardcode the Token program ID if you expect to support Token-2022 assets.

```typescript
// Check if the mint owner is Token or Token-2022
if (mintInfo.owner.toString() === 'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb') {
    // Use Token-2022 instructions
}
```

## 2. Transfer Hook Extensions

Transfers for tokens using the Transfer Hook extension require additional accounts to be passed into the transaction.

### Discovery Pattern
Use `getExtraAccountMetaListForTransfer` or similar helpers from `@solana/spl-token` (or `@solana-program/token-2022`) to dynamically resolve the required extra accounts before building the transfer instruction.

## 3. Common Client-Side Considerations

* **Transfer Fees:** If a token has transfer fees, the amount received will be less than the amount sent. Calculate this client-side and display the expected received amount to the user.
* **Non-Transferable:** If a token is soulbound (non-transferable), disable transfer UI elements to prevent guaranteed transaction failures.
* **Confidential Transfers:** Implementing confidential transfers requires specialized ZK encryption setup on the client side.
* **Metadata:** Token-2022 supports native metadata. You can read the token name, symbol, and URI directly from the mint account data, bypassing the need for Metaplex metadata accounts in some cases.
