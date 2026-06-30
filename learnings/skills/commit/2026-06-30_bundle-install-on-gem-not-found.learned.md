---
skill: wk-commit
date: 2026-06-30
type: correction
severity: medium
---

Run `bundle install` immediately when a pre-push hook fails with `GemNotFound`, then retry the push.

**What happened:** A pre-push hook failed because a gem version referenced in `Gemfile.lock` was not installed locally (the base branch had bumped the gem, and the local bundle was stale after a rebase). The agent surfaced the raw error and stopped rather than running `bundle install` and retrying.

**Root cause:** The skill's pre-push hook failure handling does not enumerate common, self-healing error classes. A `GemNotFound` / `Bundler::GemNotFound` error from a Ruby-based hook is always fixable by syncing the bundle — it is not an indication that the push itself is wrong or needs user input.

**Suggested fix:** When a pre-push hook exits with a Bundler error (`GemNotFound`, `Could not find gem`, `Bundler::GemNotFound`), run `bundle install` automatically and retry the push once. Treat this as a self-healing step, not a blocker to surface. Only escalate if `bundle install` itself fails or the hook fails again after installation.
