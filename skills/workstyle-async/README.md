# wk-workstyle-async

> Enforces safe asynchronous and concurrent patterns for every promise, await, callback, goroutine, thread, channel, and mutex the agent writes. Project config always wins; this skill fills gaps only.

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic whenever the agent writes or edits async or concurrent code |
| User-invocable | `/wk-workstyle-async scan` — full tree; `/wk-workstyle-async check <path>` — one file |

## Rules at a Glance

- No temporal dependencies between async calls — make every cross-operation dependency explicit (await/join/channel/mutex).
- No unbounded async chaining — `.then()` past 2 levels becomes a named async function with `await` per step.
- Propagate errors from async operations — never silently swallow; log and re-throw, or justify the ignore in a one-line comment.

## Noteworthy

- **Project config is always authoritative.** Defers to any active linter /
  formatter config; fills gaps only.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the [`wk-workstyle`](../workstyle/README.md) orchestrator runs
  the shared project-style-authority probe (Step 0) and routes to this skill
  based on the touched files / change type. This skill is also independently
  model-invocable on adjacent work.
- Temporal coupling between concurrent ops is treated as a latent race condition — the dependency must be explicit (await/join/channel/mutex).
- Silent `.catch(() => {})` is always a finding; ignoring an async error requires a one-line justification comment.
