---
skill: wk-workstyle-rails
date: 2026-06-29
type: gap
severity: high
---

Always run `bin/setup` before attempting manual gem install or bundle exec in a Rails repo.

**What happened:** Agent tried `bundle exec` / `bin/<app>-config` commands that failed with GemNotFound because the project environment was not initialized. The agent then gave up on infrastructure commands that were needed to fix the root cause, instead pivoting to unrelated code changes.

**Root cause:** No step in the skill instructs the agent to check for and run `bin/setup` (or equivalent) when gem commands fail. Many Rails repos wrap environment initialization in `bin/setup` — often delegating to a dev environment tool (`gdev setup`, `mise exec`, etc.) — and `bundle exec` commands fail until that script has been run.

**Suggested fix:** Add a pre-flight step: when any `bundle exec`, `bin/*`, or `rails` command fails with a gem or environment error, check for `bin/setup` and instruct the user to run it (or run it directly if authorized) before retrying. Document that `bin/setup` is the canonical entry point for Rails project initialization and should be checked before any manual environment repair.
