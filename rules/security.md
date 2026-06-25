# Frontend Security Rules

Blockchain applications handle user funds. Security flaws in the frontend can lead to catastrophic loss. The `react-engineer` and `frontend-architect` must strictly adhere to these security principles.

## 1. Phishing & Malicious Simulation Prevention
- **Human Readable Transactions:** Never obscure what a transaction is doing. Always present a clear UI breakdown of exactly what assets are moving, to whom, and how much the fees are.
- **Avoid Blind Signing:** If you implement a generic "Sign Message" feature, ensure the message is strictly parsed and displayed to the user. Do not pass unvalidated hex payloads directly to `signMessage()`.

## 2. Address & Input Validation
- **Never Trust User Input:** A user attempting to transfer tokens might input an invalid string or a malicious program address.
- **Address Validation:** Before building a transaction, validate that the input successfully passes `address()` (in web3.js v2) or `PublicKey.isOnCurve()`. 
- **Integer Overflows:** A malicious user might input a negative number or a massive exponent. Validate all token amounts using `zod` schemas enforcing minimums (`min(0)`) and maximums.

## 3. Environment Variable Safety
- **Leak Prevention:** Only prefix environment variables with `NEXT_PUBLIC_` if they are explicitly required in the client browser (e.g., `NEXT_PUBLIC_RPC_URL`).
- **Secret Keys:** Never, under any circumstances, place a raw Keypair or a Secret Key inside the frontend codebase or inside a client-side environment variable. All programmatic signing must occur on a secure backend server.

## 4. Wallet Adapter Vulnerabilities
- **Auto-Connect Risks:** Be cautious with `autoConnect={true}` in the `WalletProvider`. Ensure the user is explicitly aware when their wallet connects to your dApp to prevent subtle session hijacking via malicious iframes.
- **Origin Checking:** When building Wallet Standard integrations, heavily enforce origin checking so third-party malicious sites cannot silently pass payloads to your application layer.

## 5. RPC Data Sanitization
- Data fetched from the blockchain is technically "user input" because anyone can write to the blockchain.
- If an on-chain account stores a string (e.g., a username or a token name), you MUST sanitize it before rendering it into the DOM to prevent Cross-Site Scripting (XSS) attacks. React handles most text escaping natively, but be extremely careful if using `dangerouslySetInnerHTML`.
