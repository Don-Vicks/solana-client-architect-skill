# Websockets & Real-Time Data

Fetching data via polling using React Query's `refetchInterval` is acceptable for non-critical data, but highly inefficient and costly for real-time states (e.g., live trading prices, chat messages, or instant transaction feedback). You must utilize Solana's WebSockets.

## 1. Account Subscriptions (`onAccountChange`)

When you need an instant UI update the millisecond an on-chain account changes, implement a websocket listener inside a React `useEffect` loop, and tie it to React Query.

### Implementation Blueprint

1. Inside a custom hook, access the Solana `Connection` object.
2. In a `useEffect`, register the `onAccountChange` listener.
3. Upon receiving a payload, explicitly update the React Query cache using `queryClient.setQueryData()` rather than forcing a heavy refetch.

```typescript
import { useEffect } from 'react';
import { useConnection } from '@solana/wallet-adapter-react';
import { useQueryClient } from '@tanstack/react-query';
import { PublicKey } from '@solana/web3.js';

export function useAccountSubscription(accountPubkey: PublicKey | null) {
  const { connection } = useConnection();
  const queryClient = useQueryClient();

  useEffect(() => {
    if (!accountPubkey) return;

    // Register WebSocket Listener
    const subscriptionId = connection.onAccountChange(
      accountPubkey,
      (accountInfo) => {
        // Example: Decode the raw data buffer into a typed object
        const decodedData = MyProgramDecoder.decode(accountInfo.data);

        // Instantly mutate the React Query cache, triggering a UI re-render
        queryClient.setQueryData(
          ['my-program', 'account', accountPubkey.toBase58()],
          decodedData
        );
      },
      'confirmed'
    );

    // CRITICAL: Always clean up the WebSocket connection on unmount
    return () => {
      connection.removeAccountChangeListener(subscriptionId);
    };
  }, [connection, accountPubkey, queryClient]);
}
```

## 2. Program Subscriptions (`onProgramAccountChange`)

To listen for ANY new account created by a program (e.g., a new listing on a marketplace), utilize `onProgramAccountChange`.
- **Caution:** This is an extremely heavy RPC call. You MUST pass `filters` (e.g., `dataSize` or specific byte offsets) to restrict the websocket payload strictly to the accounts you care about.
- **RPC Support:** Note that many public or free RPCs disable `programSubscribe` due to load. Ensure the architect specifies the requirement for a premium RPC provider (Helius, QuickNode, Triton) when utilizing this feature.
