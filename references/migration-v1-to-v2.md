# Migration Guide: v1 to v2 (`@solana/kit`)

This is a quick reference for migrating from `@solana/web3.js` (v1) to `@solana/kit` (v2).

## Concept Mapping

| Concept | v1 (`@solana/web3.js`) | v2 (`@solana/kit`) |
|---|---|---|
| **Package** | `@solana/web3.js` (1.x) | `@solana/kit` (2.x) |
| **Address** | `new PublicKey('...')` | `address('...')` |
| **Key Pair** | `Keypair.generate()` | `await generateKeyPair()` |
| **Transaction** | `new Transaction()` | `createTransactionMessage({ version: 0 })` |
| **Add Instruction** | `tx.add(ix)` | `appendTransactionMessageInstruction(ix, msg)` |
| **Fee Payer** | `tx.feePayer = pubkey` | `setTransactionMessageFeePayer(addr, msg)` |
| **Blockhash** | `tx.recentBlockhash = hash` | `setTransactionMessageLifetimeUsingBlockhash(info, msg)` |
| **Compile** | implicit | `compileTransaction(msg)` |
| **Sign** | `tx.sign(keypair)` | `signTransactionMessageWithSigners(msg)` |
| **Send** | `connection.sendTransaction(tx)` | `signAndSendTransactionMessageWithSigners(msg)` |
| **PDA** | `PublicKey.findProgramAddressSync(seeds, id)` | `await getProgramDerivedAddress({ programAddress, seeds })` |
| **Confirm** | `connection.confirmTransaction(sig)` | `signatureNotifications` subscription |
| **Connection** | `new Connection(url)` | `createSolanaRpc(url)` |
| **WebSocket** | `connection.onAccountChange(...)` | `rpcSubscriptions.accountNotifications(...)` |

## Common Recipes

### 1. Fetching an Account
**v1:**
```typescript
const info = await connection.getAccountInfo(pubkey);
```
**v2:**
```typescript
const response = await rpc.getAccountInfo(address('...')).send();
const info = response.value;
```

### 2. Sending a Transfer
**v1:**
```typescript
const tx = new Transaction().add(SystemProgram.transfer({ from, to, lamports }));
const sig = await sendTransaction(tx, connection);
```
**v2:**
```typescript
const tx = pipe(
    createTransactionMessage({ version: 0 }),
    m => setTransactionMessageFeePayer(fromAddress, m),
    m => setTransactionMessageLifetimeUsingBlockhash(blockhashInfo, m),
    m => appendTransactionMessageInstruction(getTransferInstruction({ from, to, amount }), m),
    compileTransaction
);
const sig = await signAndSendTransactionMessageWithSigners(tx);
```

### 3. Deriving a PDA
**v1:**
```typescript
const [pda, bump] = PublicKey.findProgramAddressSync([Buffer.from("seed")], programId);
```
**v2:**
```typescript
import { getUtf8Encoder } from '@solana/kit';
const [pda, bump] = await getProgramDerivedAddress({
    programAddress,
    seeds: [getUtf8Encoder().encode("seed")]
});
```

### 4. Confirming a Transaction
**v1:**
```typescript
await connection.confirmTransaction(signature, 'confirmed');
```
**v2:**
```typescript
await rpcSubscriptions.signatureNotifications(signature, { commitment: 'confirmed' })
    .subscribe({ abortSignal: controller.signal });
```
