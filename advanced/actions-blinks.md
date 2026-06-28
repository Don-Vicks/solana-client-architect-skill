# Solana Actions & Blinks

Solana Actions and Blinks provide a standard for delivering interactive Solana transactions directly to users across the web.

## 1. Solana Actions

An Action is an API endpoint that returns a transaction for the user to sign.

### Spec Overview
* `GET /api/action`: Returns metadata (icon, title, description, parameters).
* `POST /api/action`: Receives user input (like their account address) and returns a fully built, serialized transaction.

### Next.js API Route Pattern

Use the `@solana/actions` package to construct standard responses.

```typescript
// app/api/action/route.ts
import { ActionGetResponse, ActionPostRequest, ActionPostResponse } from "@solana/actions";

export async function GET() {
  const payload: ActionGetResponse = {
    icon: 'https://example.com/icon.png',
    title: 'My Action',
    description: 'Execute this awesome action.',
    label: 'Execute',
  };
  return Response.json(payload);
}

export async function POST(req: Request) {
  const body: ActionPostRequest = await req.json();
  const userAccount = body.account;

  // 1. Build transaction for userAccount
  // 2. Set blockhash and fee payer
  // 3. Serialize transaction to base64
  
  const payload: ActionPostResponse = {
    transaction: serializedBase64Tx,
    message: "Transaction ready!",
  };
  return Response.json(payload);
}
```

## 2. Blinks (Blockchain Links)

Blinks are URLs that wallets and platforms unfurl to display an Action UI.

* **URL Format:** `solana-action:https://example.com/api/action`
* **actions.json:** You must host an `actions.json` at your domain root mapping web routes to API endpoints.
* **Testing:** Use the Dialect Blinks Inspector (`dialect.to`) to test your Actions before integrating them into frontends.
