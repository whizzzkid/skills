# wk-workstyle-error-handling

> Enforces robust error handling — no silently swallowed errors, and a clear
> split between operational errors (handle gracefully) and programmer errors
> (fail fast).

**Version:** `2026.07.08-175435`

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic whenever the agent touches an error path — a catch/rescue/except block, an error return, or code that raises/throws |
| User-invocable | `/wk-workstyle-error-handling scan` — full tree; `/wk-workstyle-error-handling check <path>` — one file |

## Rules at a Glance

- Never swallow errors silently — every catch/rescue/except must log, re-raise, or translate to a domain error.
- Distinguish operational errors (handle gracefully) from programmer errors (throw hard, fail fast).

## Noteworthy

- **Project config is always authoritative.** Defers to any active linter /
  formatter config; fills gaps only.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the [`wk-workstyle`](../workstyle/README.md) orchestrator runs
  the shared project-style-authority probe (Step 0) and routes to this skill
  based on the touched files / change type. This skill is also independently
  model-invocable on adjacent work.
- Empty catch/rescue/except blocks are always a finding — every handler must
  log, re-raise, or translate to a domain error.
- Operational errors (timeout, missing file) are handled gracefully; programmer
  errors (contract violations) fail fast.
