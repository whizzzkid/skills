---
class: principle
---

- **Rule:** A pre-push hook failing with a Bundler error (`GemNotFound`,
  `Bundler::GemNotFound`, `Could not find gem`) is a self-healing class — run
  `bundle install`, then retry the push once. Do not surface the raw error and
  stop. Escalate only if `bundle install` fails or the hook fails again after it.
- **Why:** A stale local bundle (base branch bumped a gem; local bundle stale
  after a rebase) is always fixable by syncing the bundle — it is not a signal the
  push is wrong or needs user input.
- **Where:** Hook and verify rules.
