# /test-frontend Command

## Purpose
Run the testing suite for the frontend, ensuring that React components and Web3 hooks function correctly in isolation.

## Execution Workflow

When the user types `/test-frontend`, follow this strict workflow:

### 1. Verification of Test Environment
Check if the testing libraries are installed. Look in `package.json` for `jest`, `@testing-library/react`, and `@testing-library/jest-dom`.
If they are missing, halt and ask the user if they would like you to configure Jest for Next.js.

### 2. Execution
Run the test runner in CI mode so it does not hang the terminal:
```bash
npm run test -- --passWithNoTests --watchAll=false
```

### 3. Error Analysis and Remediation
If the test suite reports failures:
- **Analyze:** Read the console output carefully. Identify whether it is a component rendering failure (e.g., missing Wallet Context during a test render) or a logic failure in a hook.
- **Mocking Web3:** Often, Solana tests fail because `@solana/web3.js` or Wallet Adapter contexts are not mocked. If you encounter "useWallet must be used within a WalletProvider", modify the test file to wrap the component in a mock provider.
- **Fix & Rerun:** Implement the surgical fix to the component or the test file. Re-run the tests.

### 4. Two-Strike Rule
If you attempt to fix a test and it fails a second time for the same reason, **STOP**. Do not enter an infinite loop. Present the error to the user and ask for guidance.
