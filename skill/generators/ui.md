# UI & Component Generation Rules

When building the visual interface for a Solana application, your primary goal is to create a responsive, resilient, and state-aware user experience utilizing Tailwind CSS. Web3 interactions are inherently asynchronous and prone to failure; the UI must reflect this reality gracefully.

## 1. Client Components & Hook Wiring
- **Component Pragma:** Any component that imports `useWallet()`, `useQuery()`, or your custom Web3 hooks MUST begin with `"use client";` at the very top of the file.
- **Separation of Concerns:** Keep components "dumb" where possible. Pass the result of `useQuery` down as props, rather than invoking the hook inside heavily nested UI elements.

## 2. Managing Pending & Loading States
Never leave the user wondering if a button click registered.
- **Button Disablement:** If a React Query mutation `isPending` is true, the submit button MUST be `disabled`.
- **Wallet Disablement:** If `wallet.connected` is false, buttons that trigger on-chain actions MUST be `disabled` or swapped with a "Connect Wallet" button.
- **Visual Feedback:** Use lucide-react icons or Tailwind animate-spin to indicate loading states.

```tsx
// Example UI Wiring
"use client";

import { useWallet } from "@solana/wallet-adapter-react";
import { useCreateProfile } from "@/hooks/useCreateProfile";
import { useState } from "react";
import toast from "react-hot-toast"; // Or sonner

export function CreateProfileForm() {
  const { connected } = useWallet();
  const [username, setUsername] = useState("");
  const { mutateAsync: createProfile, isPending } = useCreateProfile();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!username) return;

    try {
      // Toast notifications provide real-time lifecycle updates
      const promise = createProfile({ username });
      toast.promise(promise, {
        loading: 'Confirming transaction on-chain...',
        success: 'Profile created successfully!',
        error: 'Failed to create profile.',
      });
      await promise;
      setUsername(""); // Clear form on success
    } catch (err) {
      // The hook handles the console error, the UI handles the UX
    }
  };

  if (!connected) {
    return <p className="text-zinc-500">Please connect your wallet to create a profile.</p>;
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-4 max-w-sm">
      <input 
        type="text"
        value={username}
        onChange={(e) => setUsername(e.target.value)}
        placeholder="Enter username"
        className="px-4 py-2 bg-zinc-900 border border-zinc-800 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
        disabled={isPending}
      />
      <button 
        type="submit"
        disabled={isPending || !username}
        className="px-4 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-zinc-700 disabled:text-zinc-500 text-white font-medium rounded-md transition-colors flex justify-center items-center"
      >
        {isPending ? "Creating..." : "Create Profile"}
      </button>
    </form>
  );
}
```

## 3. Data Formatting & BigInt Parsing
- **Safety First:** Data fetched from Solana programs (lamports, token amounts) is frequently returned as `BigInt` or `BN`. 
- **Rule:** Never render an unformatted `BigInt` directly into JSX, and never do blind floating-point math on it. Use specific formatter functions that handle decimals appropriately.
  ```tsx
  // Example: Converting lamports to SOL securely in the UI
  <p className="text-xl font-bold">
    {(Number(balance) / 1e9).toFixed(2)} SOL
  </p>
  ```

## 4. Modern Aesthetics
- Utilize modern Tailwind utility classes.
- Prefer neutral dark themes (`bg-zinc-950`, `text-zinc-100`) with subtle borders (`border-zinc-800/50`).
- Add micro-interactions: `transition-all duration-200 hover:scale-[1.02] active:scale-[0.98]`.
