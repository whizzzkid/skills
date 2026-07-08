# wk-workstyle-typescript

> Idiomatic, type-safe TypeScript/JavaScript on every file the agent writes or
> edits. Project tsconfig/eslint/prettier config wins.

**Version:** `2026.07.08-175435`

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic whenever the agent writes or edits a `.ts`/`.tsx`/`.js`/`.jsx`/`.mjs`/`.cjs` file |
| User-invocable | `/wk-workstyle-typescript scan` — full tree; `/wk-workstyle-typescript check <path>` — one file |

## Rules at a Glance

- `const` over `let`; never `var`.
- No `any` — use `unknown` and narrow before use.
- Explicit return types on public functions.
- Arrow functions for callbacks; named functions for top-level declarations.
- Nullish coalescing (`??`) over `||` for defaulting.
- Optional chaining (`?.`) over guard chains.
- Destructure at the call site when using ≥ 3 fields from an object.
- `Promise.all` for independent async operations; never sequential `await`.

## Noteworthy

- **Project config is always authoritative.** Defers to any active linter /
  formatter config; fills gaps only.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the [`wk-workstyle`](../workstyle/README.md) orchestrator runs
  the shared project-style-authority probe (Step 0) and routes to this skill
  based on the touched files / change type. This skill is also independently
  model-invocable on adjacent work.
- `any` is banned — use `unknown` and narrow; `??`/`?.` replace `||` and guard
  chains for null-safety.
- Independent async operations use `Promise.all`, not sequential awaits.
