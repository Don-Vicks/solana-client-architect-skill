# React Rules for Solana Frontends

Professional Solana applications require highly performant, responsive, and resilient React implementations. Follow these strict architectural guidelines.

## 1. Next.js App Router Architecture
- **Server Components Default:** By default, all components are Server Components. This reduces JavaScript bundle sizes significantly.
- **Isolating Client Boundaries:** The Solana Wallet Adapter (`useWallet`, `useConnection`) and React Query (`useQuery`) require React Context, which only functions in Client Components. 
- **Rule:** Push `"use client";` declarations as far down the component tree as possible. Do not put `"use client";` on `layout.tsx` or `page.tsx` unless absolutely unavoidable. Instead, create wrapper components (e.g., `<WalletConnectButton />`) that manage the client state.

## 2. Rendering Optimization & Performance
Web3 RPC calls can be slow. Your UI must compensate by being instantly responsive.
- **Memoization:** Wrap complex components in `React.memo()`. Use `useMemo` for derived data (like calculating total balances from an array of accounts) to prevent re-calculations on every render.
- **Callback Stability:** Functions passed down as props to child components MUST be wrapped in `useCallback` to prevent unnecessary re-rendering of children.

## 3. Wallet Connection Resilience
- **Assumption of Disconnection:** Never assume the wallet is connected. The UI must render a meaningful fallback (not just a blank screen) when `wallet.connected === false`.
- **Prompting:** Utilize the `@solana/wallet-adapter-react-ui` components to provide standard, recognizable connection prompts.

## 4. Hook Encapsulation (The Custom Hook Rule)
- **Separation of Concerns:** React components (`.tsx`) should only contain rendering logic, state binding, and Tailwind classes.
- **Rule:** All Web3 interactions, RPC calls, and transaction building MUST be abstracted into custom hooks (e.g., `useTransferTokens.ts`, `useFetchUserProfile.ts`).
- **Why?** This ensures that blockchain logic is reusable, testable in isolation, and keeps the UI layer clean.

## 5. Asynchronous UI Patterns
- **Loading States:** Every mutation MUST utilize the `isPending` boolean from React Query to disable buttons and show localized loading spinners.
- **Graceful Degradation:** If an RPC node goes down or a query fails, use React Query's `isError` to show a fallback UI or retry button, preventing the entire application from white-screening.

## 6. Prohibited Practices
- **Raw Web3 in JSX:** Do not import `@solana/web3.js` or define instructions directly inside a `.tsx` component's render function.
- **Missing Dependency Arrays:** Never leave `useEffect` or `useMemo` dependency arrays incomplete. This leads to stale closures and incorrect blockchain state representation.
