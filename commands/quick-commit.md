# /quick-commit Command

## Purpose
Commit changes to the repository using strict Conventional Commits formatting. This ensures clear git history and facilitates automated versioning.

## Execution Workflow

When the user types `/quick-commit`, execute the following sequence:

### 1. Diff Analysis
Run `git status` and `git diff` to analyze exactly what has been modified, added, or deleted.
Understand the *intent* of the changes (e.g., was this a bug fix? a new React hook? a UI change?).

### 2. Determine Conventional Prefix
Select the most accurate prefix:
- `feat:` (New feature, e.g., adding a wallet connect button)
- `fix:` (Bug fix, e.g., fixing a React hydration error)
- `refactor:` (Code change that neither fixes a bug nor adds a feature, e.g., switching to React Query)
- `style:` (Changes that do not affect the meaning of the code, e.g., Tailwind class adjustments)
- `docs:` (Documentation changes, e.g., updating SKILL.md)
- `chore:` (Build process or auxiliary tool changes, e.g., updating dependencies)

### 3. Draft the Message
Draft a concise, imperative present-tense message.
*Example:* `feat: integrate React Query for token balance fetching`

### 4. Execute Commit
Run the staging and commit commands.
```bash
git add .
git commit -m "<prefix>: <message>"
```

### 5. Report
Inform the user that the commit was successful and display the commit hash and message.
