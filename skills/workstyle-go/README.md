# wk-workstyle-go

> Enforces idiomatic Go authoring conventions on every `.go` file the agent writes or edits.

**Version:** `2026.06.12-021636`

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic whenever the agent writes or edits a `.go` file |
| User-invocable | `/wk-workstyle-go scan` — full tree; `/wk-workstyle-go check <path>` — one file |

## Rules at a Glance

- Handle errors immediately as values after every call that returns one.
- Wrap errors with `fmt.Errorf("context: %w", err)`; never discard them.
- Use table-driven tests for any function with multiple input variants.
- Keep package-internal state unexported; export only the minimal API.
- No `panic` in library code — return an error instead.
- Place `defer` cleanup (close, unlock) immediately after acquire.

## Noteworthy

- **Project config is always authoritative.** Defers to any active linter /
  formatter config; fills gaps only.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the [`wk-workstyle`](../workstyle/README.md) orchestrator runs
  the shared project-style-authority probe (Step 0) and routes to this skill
  based on the touched files / change type. This skill is also independently
  model-invocable on adjacent work.
- Errors are values handled at the call site and wrapped with `fmt.Errorf("…: %w", err)` — never discarded; no `panic` in library code.
- `defer` cleanup goes immediately after acquire; only the minimal API is exported.
