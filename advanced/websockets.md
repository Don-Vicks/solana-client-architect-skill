# Websockets & Real-Time Data

Fetching data via polling using React Query's `refetchInterval` is acceptable for non-critical data, but highly inefficient and costly for real-time states (e.g., live trading prices, chat messages, or instant transaction feedback). You must utilize Solana's WebSockets.

## Dual-Track Architecture

### Track A: v1 (Anchor Context)

When using Anchor and the v1 `@solana/web3.js` `Connection` object:

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

    const subscriptionId = connection.onAccountChange(
      accountPubkey,
      (accountInfo) => {
        const decodedData = MyProgramDecoder.decode(accountInfo.data);
        queryClient.setQueryData(
          ['my-program', 'account', accountPubkey.toString()],
          decodedData
        );
      },
      'confirmed'
    );

    return () => {
      // CRITICAL: Always clean up
      connection.removeAccountChangeListener(subscriptionId);
    };
  }, [connection, accountPubkey, queryClient]);
}
```

For program-wide subscriptions, use `onProgramAccountChange` with strictly defined `filters` (e.g., `dataSize`, `memcmp`) to avoid massive payloads.

### Track B: v2 (`@solana/kit`)

For modern applications using the v2 API, use `createSolanaRpcSubscriptions` and `AbortController`.

```typescript
import { useEffect } from 'react';
import { createSolanaRpcSubscriptions, address } from '@solana/kit';
import { useQueryClient } from '@tanstack/react-query';

export function useAccountSubscriptionV2(accountAddress: string | null) {
  const queryClient = useQueryClient();

  useEffect(() => {
    if (!accountAddress) return;
    
    const rpcSubscriptions = createSolanaRpcSubscriptions('wss://api.devnet.solana.com');
    const controller = new AbortController();

    async function subscribe() {
      try {
        const notifications = await rpcSubscriptions.accountNotifications(
          address(accountAddress), 
          { commitment: 'confirmed' }
        ).subscribe({ abortSignal: controller.signal });

        for await (const notification of notifications) {
          const decodedData = decodeMyData(notification.value.data);
          queryClient.setQueryData(
            ['my-program', 'account', accountAddress],
            decodedData
          );
        }
      } catch (err) {
        if (err.name === 'AbortError') return;
        console.error("Subscription error", err);
        // Implement reconnection strategy with exponential backoff here
      }
    }

    subscribe();

    return () => controller.abort(); // Cleanup on unmount
  }, [accountAddress, queryClient]);
}
```

#### Signature Confirmation Subscription (v2)

To confirm a transaction efficiently:

```typescript
await rpcSubscriptions.signatureNotifications(signature, { commitment: 'confirmed' })
  .subscribe({ abortSignal: controller.signal });
```

## Premium RPC Requirement

Note that many public or free RPCs disable `programSubscribe` (and sometimes `accountSubscribe`) due to load. Ensure you specify the requirement for a premium RPC provider (Helius, QuickNode, Triton) when utilizing websocket features in production.
