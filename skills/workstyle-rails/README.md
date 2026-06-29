# wk-workstyle-rails

> Use when a Rails project command fails to start — `bundle exec`, `bin/*`,
> `rake`, or `rails` erroring with a missing gem or uninitialized environment.
> Enforces running the project's canonical bootstrap (`bin/setup`) before any
> manual gem install or environment repair. Project bootstrap scripts are
> authoritative.

**Version:** `2026.06.29-225302`

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic whenever a Rails/Ruby project command fails with a missing-gem or uninitialized-environment error |
| User-invocable | `/wk-workstyle-rails check` — report the repo's bootstrap entry point |

## Rules at a Glance

- **Bootstrap before manual repair** — on a gem/env failure, run the project
  bootstrap (`bin/setup`) before any manual `bundle install` / `gem install`.
- A failed infrastructure command means the environment is uninitialized — not
  a reason to pivot to unrelated code changes.
- `bin/setup` often delegates to a dev tool (`gdev setup`, `mise exec`, Docker);
  manual installs skip that delegation.
- Manual repair runs only when the bootstrap script is absent or has itself
  failed — and a bootstrap failure is the real bug to surface.
- Treat a slow bootstrap (gem builds, container starts) as work, not a hang.

## Noteworthy

- **Project bootstrap scripts are authoritative.** Run them; do not reinvent
  initialization by hand.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the
  [`wk-workstyle`](../workstyle/README.md) orchestrator routes to this skill
  when a Rails/Ruby project command fails with a gem or environment error. This
  skill is also independently model-invocable.
- Distilled from a field learning: an agent hit `GemNotFound` on `bundle exec`,
  gave up on the infrastructure fix, and pivoted to unrelated edits instead of
  running `bin/setup`.
