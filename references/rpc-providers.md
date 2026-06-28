# RPC Providers Reference

Selecting and configuring the right RPC provider is crucial for performance and feature support.

## 1. Leading Providers

### Helius
* **Features:** DAS (Digital Asset Standard) API for NFTs/cNFTs, Enhanced Transactions API (human-readable tx history), Priority Fee API, Webhooks.
* **SDK:** `helius-sdk`
* **Best for:** NFT platforms, complex transaction parsing, modern dApps.

### QuickNode
* **Features:** Marketplace add-ons (Jupiter swaps, NFT tools), DAS API support, WebSocket and gRPC endpoints.
* **Best for:** Enterprise scale, multi-chain projects.

### Triton (Project Yellowstone)
* **Features:** gRPC streaming via `@triton-one/yellowstone-grpc`.
* **Best for:** High-throughput data ingestion, MEV bots, scenarios where WebSocket latency is unacceptable.

## 2. Choosing an RPC

* **Free/Public RPCs** (`api.mainnet-beta.solana.com`): Heavily rate-limited, block `programSubscribe`, often unstable. **Use for development only.**
* **Paid/Premium RPCs:** Essential for production. Required for Websocket program subscriptions, DAS APIs, and reliable priority fee estimation.

## 3. Configuration Pattern

Never hardcode RPC URLs. Use environment variables with fallbacks, and structure them by cluster.

```typescript
// config/rpc.ts
export const RPC_CONFIGS = {
  'mainnet-beta': {
    http: process.env.NEXT_PUBLIC_MAINNET_RPC_URL || 'https://api.mainnet-beta.solana.com',
    ws: process.env.NEXT_PUBLIC_MAINNET_WS_URL || 'wss://api.mainnet-beta.solana.com',
  },
  'devnet': {
    http: process.env.NEXT_PUBLIC_DEVNET_RPC_URL || 'https://api.devnet.solana.com',
    ws: process.env.NEXT_PUBLIC_DEVNET_WS_URL || 'wss://api.devnet.solana.com',
  },
} as const;

export type SupportedCluster = keyof typeof RPC_CONFIGS;

export function getRpcUrl(cluster: SupportedCluster = 'mainnet-beta') {
    return RPC_CONFIGS[cluster].http;
}
```
