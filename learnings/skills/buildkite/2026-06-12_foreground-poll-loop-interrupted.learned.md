---
skill: wk-buildkite
date: 2026-06-12
type: correction
severity: medium
---

A blocking `until [...] bk build view` poll loop must never run in the foreground.

**What happened:** After a `git push`, the agent ran an `until` loop calling `bk build view` to poll for CI completion. The loop blocked the turn. The user interrupted it and said to mark the PR ready without waiting.

**Root cause:** wk-buildkite's monitoring guidance shows `bk build view` status checks but does not explicitly prohibit foreground poll loops. A blocking `until` loop with no timeout stalls every other action until CI finishes — often 5–10 minutes.

**Suggested fix:** Add to the "Monitoring Builds After Push" section:

> Never run a polling loop (`until`/`while`) in the foreground. Run a single status check and report the current state; if CI is still running, tell the user and offer to check again. Foreground polling blocks the turn and forces the user to interrupt to regain control. Use `run_in_background: true` for any watch command that takes >10s.
