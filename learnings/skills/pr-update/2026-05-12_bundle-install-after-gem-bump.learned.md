---
skill: wk-pr-update
date: 2026-05-12
type: gap
severity: low
---

Patch-replay validation may require dependency install before running tests when base branch has bumped a package.

**What happened:** After patch-replay reset to new base, `bundle exec rspec` failed with `GemNotFound` because the base branch had bumped a gem version not yet installed locally. The failure looked like a test regression but was a missing install step.

**Root cause:** Stage 5 (re-validate) assumes the local gem cache matches the new base's Gemfile.lock, but patch-replay onto a bumped-gem base invalidates that assumption.

**Suggested fix:** Before running the test suite in Stage 5, check if Gemfile.lock changed between `$OLD_BASE` and `$BASE_REF` — if it did, run `bundle install` (or equivalent for the project's package manager) before the test command.
