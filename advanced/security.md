# Security Guide

Security is the most critical aspect of Solana client architecture. Follow this guide to prevent fund loss and exploits.

## 1. Input Validation

* **Address Validation:** Always validate that strings are legitimate Solana addresses.
  * v2: `import { isAddress } from '@solana/kit'; if (!isAddress(input)) throw new Error('Invalid');`
  * v1: Wrap `new PublicKey(input)` in a `try/catch`.
* **Amount Validation:** Check for negative values, `NaN`, floating-point overflow, and verify the amount does not exceed the user's available balance before building the transaction.
* **Integer Bounds:** When converting inputs to `u64` or `i64`, use `BigInt` to prevent exceeding `Number.MAX_SAFE_INTEGER`.
* **String Length:** Validate string lengths against the program's defined maximum constraints.

## 2. Transaction Security

* **Simulate Before Signing:** ALWAYS simulate the transaction. If simulation fails, do not prompt the user to sign.
* **Transaction Inspection:** In development, log the accounts and instructions. In production, provide a clear UI summary of the expected state changes.
* **Blockhash Freshness:** Fetch a new blockhash *immediately* before prompting for a signature. Stale blockhashes cause silent failures.
* **Commitment Levels:** Use `confirmed` for general reads. Use `finalized` for high-value financial operations. Never rely on `processed` for user-facing UI updates.
* **Preflight Checks:** Ensure `preflightCommitment: 'confirmed'` is set to catch errors at the RPC level before broadcasting.

## 3. Wallet Security

* **No Private Keys:** Never ask for, accept, or manage private keys in frontend code. Use the wallet adapter.
* **Disconnection Handling:** Check `wallet.connected` prior to any mutation. Handle unexpected disconnections gracefully.
* **Wallet Switching:** If the user changes active wallets, clear all React Query caches containing user-specific data to prevent leaking state between accounts.
* **No Auto-Approve:** Never attempt to bypass the wallet's approval popup. Each transaction requires explicit consent.

## 4. RPC Security

* **Trusted Endpoints:** Never allow users to define arbitrary RPC endpoints in production. Malicious RPCs can spoof simulation results and drain funds.
* **Rate Limiting:** Implement client-side rate limiting. Use React Query `staleTime` to avoid spamming the RPC.
* **Data Exposure:** Never expose RPC API keys or internal endpoint URLs in client bundles. Use proxy API routes if necessary.

## 5. Frontend-Specific Threats

* **Supply Chain Attacks:** Pin all `@solana/*` dependency versions. Regularly audit your lockfile.
* **XSS:** Sanitize any strings fetched from on-chain data before rendering them in the DOM.
* **Drainer Contracts:** Display clear warnings if a transaction interacts with an unrecognized program ID.
* **Clipboard Hijacking:** If providing a "Copy Address" button, ensure the copied content matches the intended address exactly.

## 6. PDA Security

* **Seed Uniqueness:** Ensure PDA derivation seeds include unique identifiers (like the user's pubkey) to prevent cross-account data pollution.
* **Canonical Bumps:** Always use the canonical bump returned by the derivation function (`getProgramDerivedAddress`).
* **Ownership Verification:** When fetching an account, assert that its `owner` matches your expected program ID.

## 7. Security Checklist

Run through this before generating any mutation code:

- [ ] All user inputs validated (addresses, amounts, strings)
- [ ] Transaction simulated before signing
- [ ] Fresh blockhash obtained
- [ ] Correct commitment level used
- [ ] Wallet connection state checked
- [ ] Error messages are user-friendly (no raw errors)
- [ ] PDA seeds are unique per user
- [ ] Account ownership verified after fetch
- [ ] No private keys in frontend code
- [ ] RPC endpoint is trusted
- [ ] Dependencies pinned and audited
