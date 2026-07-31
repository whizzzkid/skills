# wk-workstyle-testing

> Enforces the test quality bar — new-function/branch coverage, behavioral
> assertions, and mandatory sad-path tests for every error branch.

**Version:** `2026.07.31-015104`

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic whenever the agent writes or modifies tests |
| User-invocable | `/wk-workstyle-testing scan` — full tree; `/wk-workstyle-testing check <path>` — one file |

## Rules at a Glance

- Cover new lines: every non-trivial function/branch added in the diff needs a test (narrow exceptions only).
- Tests assert observable behavior, not internal state or private method calls.
- Shape/structure assertions never prove a feature works — drive the real path end-to-end against real values instead.
- Sad-path tests are mandatory for every error-handling branch.
- Screenshot-exclusion tests compare decoded pixels with a manually excluded
  baseline plus a visible negative control; encoded bytes and computed ancestor
  visibility are not proof.

## Noteworthy

- **Project config is always authoritative.** Defers to any active linter /
  formatter config; fills gaps only.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the [`wk-workstyle`](../workstyle/README.md) orchestrator runs
  the shared project-style-authority probe (Step 0) and routes to this skill
  based on the touched files / change type. This skill is also independently
  model-invocable on adjacent work.
- Sad-path tests are mandatory for every error branch — a throwing/error-returning
  function with no matching test is untested error handling.
- Complements [`wk-testing-skeleton`](../testing-skeleton/README.md): skeleton plans the tests, this skill gates
  the written suite (behavior over implementation, new-path coverage).
- Prefer `display: none` when screenshot capture must temporarily exclude an
  entire UI subtree; descendants can override an ancestor's
  `visibility: hidden`.
