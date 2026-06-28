# Testing Rules

Test every hook and transaction flow. Use unit tests for hook logic, integration tests for on-chain behavior, and mock RPC for deterministic CI runs.

## 1. Unit Testing Hooks

Use `@testing-library/react-hooks` (or `renderHook` from `@testing-library/react` v14+) with a custom wrapper that provides query client and wallet context.

```tsx
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useFetchProfile } from './useFetchProfile';

function createWrapper() {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={qc}>{children}</QueryClientProvider>
  );
}

test('returns null for non-existent account', async () => {
  const { result } = renderHook(
    () => useFetchProfile(somePubkey),
    { wrapper: createWrapper() }
  );
  await waitFor(() => expect(result.current.isSuccess).toBe(true));
  expect(result.current.data).toBeNull();
});
```

> **Tip:** Disable `retry` in tests to avoid slow, flaky suites.

## 2. Mocking RPC with MSW

Use `msw` (Mock Service Worker) to intercept JSON-RPC calls for deterministic, offline-capable tests.

```typescript
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

const rpcHandler = http.post('http://127.0.0.1:8899', async ({ request }) => {
  const body = await request.json();

  if (body.method === 'getAccountInfo') {
    return HttpResponse.json({
      jsonrpc: '2.0', id: body.id,
      result: { value: { data: ['BASE64_ENCODED', 'base64'], owner: PROGRAM_ID, lamports: 1_000_000 } },
    });
  }

  // Fallback
  return HttpResponse.json({ jsonrpc: '2.0', id: body.id, result: null });
});

const server = setupServer(rpcHandler);
beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## 3. Integration Testing with solana-bankrun / LiteSVM

For full on-chain integration tests, use `solana-bankrun` (fork of `solana-test-validator` in-process) or `litesvm`.

```typescript
import { start } from 'solana-bankrun';

test('creates a profile on-chain', async () => {
  const context = await start(
    [{ name: 'my_program', programId: PROGRAM_ID }],
    [] // optional initial accounts
  );
  const client = context.banksClient;

  // Build, sign, and send transaction
  const tx = /* ... build your transaction ... */;
  await client.processTransaction(tx);

  // Fetch and assert account state
  const account = await client.getAccount(profilePda);
  expect(account).not.toBeNull();
  // Decode and verify fields
});
```

> **LiteSVM** is a lighter alternative: `const svm = new LiteSVM(); svm.addProgram(programId, soPath);`

## 4. Testing Transaction Flows

For mutation hooks, verify the full lifecycle:

```typescript
test('mutation invalidates cache on success', async () => {
  const qc = new QueryClient();
  const invalidateSpy = vi.spyOn(qc, 'invalidateQueries');

  const { result } = renderHook(() => useCreateProfile(), {
    wrapper: createWrapper(qc),
  });

  await result.current.mutateAsync({ username: 'alice' });

  expect(invalidateSpy).toHaveBeenCalledWith(
    expect.objectContaining({ queryKey: expect.arrayContaining(['my-program', 'profile']) })
  );
});
```

**Checklist for every transaction test:**
- Assert the correct instructions were built
- Verify cache invalidation fires via `onSettled`
- Test error paths (wallet disconnected, insufficient funds, program errors)
- Confirm UI state transitions if testing components end-to-end
