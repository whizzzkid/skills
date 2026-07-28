# wk-workstyle-docs

> Documentation-comment gate — requires public-API docs, WHY-not-WHAT decision
> comments, and mandatory removal of stale comments when editing adjacent code.

**Version:** `2026.07.28-171116`

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic whenever the agent adds or edits a comment, docstring, or public function/class/method |
| User-invocable | `/wk-workstyle-docs scan` — full tree; `/wk-workstyle-docs check <path>` — one file |

## Rules at a Glance

- Every new public function, method, or class gets a JSDoc / docstring /
  Rustdoc / Go doc / YARD block — purpose, typed params, return shape,
  exceptions.
- Skip docs only for trivial private helpers with a self-explanatory name and
  ≤ 2 obvious params.
- Comment WHY, not WHAT, for non-obvious algorithms, counterintuitive
  values/order, external-bug workarounds, and conscious perf trade-offs.
- Never leave a stale comment — update or delete any comment that no longer
  matches the adjacent code.

## Noteworthy

- **Project config is always authoritative.** Defers to any active linter /
  formatter config; fills gaps only.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the [`wk-workstyle`](../workstyle/README.md) orchestrator runs
  the shared project-style-authority probe (Step 0) and routes to this skill
  based on the touched files / change type. This skill is also independently
  model-invocable on adjacent work.
- **Comment WHY, not WHAT** — decision comments are required for non-obvious
  algorithms, counterintuitive ordering, external-bug workarounds, and
  conscious perf trade-offs.
- **Stale-comment removal is mandatory** — editing code obliges updating or
  deleting any adjacent comment that no longer matches.
