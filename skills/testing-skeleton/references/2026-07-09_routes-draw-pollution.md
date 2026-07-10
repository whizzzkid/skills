---
class: principle
skill: wk-testing-skeleton
date: 2026-07-09
---

# Restore shared/global state a test replaces

**Rule:** A test that mutates process- or framework-level shared state (redraws
a route table, monkeypatches a class method, swaps a global registry/singleton)
must restore the original in an `after`/teardown hook. Framework-provided
isolation (transactional DB rollback, per-example object doubles) does not cover
state a test explicitly replaces at the module/class/framework level.

**Why:** The pollution is invisible until another test depends on the full
un-mutated state — the failure is order-dependent (passes alone, fails only
when run after the polluting test), so it surfaces as unrelated tests breaking
after a suite reorder or a nearby new test.

**Where:** Stage 3: Write the tests — "Restore shared/global state a test
mutates" (Rails example: `routes.draw` inside a controller spec must restore
via `Rails.application.reload_routes!`).
