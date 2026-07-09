# wk-workstyle-ruby

> Use when writing or editing Ruby (.rb files, bin scripts loaded as Ruby) —
> enforces predicate `?` / bang `!` naming, frozen_string_literal, guard
> returns, enumerable methods, specific exception subclasses, and ASCII-only
> comments. Project RuboCop config wins.

**Version:** `2026.07.09-223249`

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic whenever the agent writes or edits a `.rb` file or a bin script loaded as Ruby |
| User-invocable | `/wk-workstyle-ruby scan` — full tree; `/wk-workstyle-ruby check <path>` — one file |

## Rules at a Glance

- Predicate methods end in `?`; mutating methods end in `!`.
- `frozen_string_literal: true` magic comment in every file.
- Guard `return` / `next` / `break` at the top of a method over `unless … else`.
- Prefer `map`, `select`, `reduce` over imperative loops.
- `raise` specific exception subclasses, not bare `RuntimeError`.
- No `rescue Exception` — rescue `StandardError` at most unless handling signals.
- ASCII-only in source comments — no em/en dashes, smart quotes, or Unicode ellipsis.
- Run `bundle exec rubocop --no-color <changed-files>` before staging; layout/style cops aren't caught by inspection.

## Noteworthy

- **Project config is always authoritative.** Defers to any active linter /
  formatter config; fills gaps only.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the [`wk-workstyle`](../workstyle/README.md) orchestrator runs
  the shared project-style-authority probe (Step 0) and routes to this skill
  based on the touched files / change type. This skill is also independently
  model-invocable on adjacent work.
- ASCII-only comments (RuboCop `Style/AsciiComments`) — em/en dashes, smart quotes, and Unicode ellipsis are findings in `.rb` files and Ruby bin scripts.
- Predicate `?` / bang `!` naming contract and `frozen_string_literal: true` are enforced per file.
