# wk-workstyle-naming

> Enforces descriptive, semantically accurate identifier names — variables,
> functions, classes, constants, and boolean predicates.

**Version:** `2026.07.08-175435`

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic whenever the agent introduces or renames any identifier |
| User-invocable | `/wk-workstyle-naming scan` — full tree; `/wk-workstyle-naming check <path>` — one file |

## Rules at a Glance

- Descriptive names; no single letters except trivial loop indices; no abbreviations.
- Constants in ALL_CAPS (deferring to language convention); name recurring/semantic literals.
- Booleans and predicate functions read as assertions (`isLoading`, `hasPermission`, `canRetry`).
- Semantic-accuracy gate: a name must truthfully describe what its value *means*, not just pass casing rules.

## Noteworthy

- **Project config is always authoritative.** Defers to any active linter /
  formatter config; fills gaps only.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the [`wk-workstyle`](../workstyle/README.md) orchestrator runs
  the shared project-style-authority probe (Step 0) and routes to this skill
  based on the touched files / change type. This skill is also independently
  model-invocable on adjacent work.
- The semantic-accuracy gate is a required finding, not advisory — a
  well-formatted name that lies about its value is still flagged.
- Constant-naming defers to language convention (Go PascalCase exports, Rust
  SCREAMING_SNAKE).
