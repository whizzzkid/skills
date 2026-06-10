---
skill: wk-workflow
date: 2026-06-10
type: correction
severity: medium
---

Never search the home directory with `find ~` to locate mise-managed gem paths.

**What happened:** When gems were not found at the expected path in a mise-managed Ruby project, the agent ran `find ~` to search for the gem installation location. This scanned the entire home directory, which is slow and signals inattention to the user.

**Root cause:** The agent treated the missing-gems problem as an exploration problem ("where are the gems?") rather than a setup problem ("run `bin/setup` or `mise exec --`"). In a mise-managed repo, `bin/setup` (which delegates to `gdev setup`) installs gems at the correct mise-scoped path. The agent should have recognized the setup step was skipped rather than hunting for gem paths manually.

**Suggested fix:** When `bundle exec` or `bin/rspec` fails with GemNotFound in a mise-managed repo (`.mise.toml` present), the first action must be `bin/setup` (not a `find` sweep). If gems are installed, always invoke test commands via `mise exec -- bin/rspec` so the mise-managed Ruby and bundler are in scope.
