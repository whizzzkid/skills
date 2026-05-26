---
skill: wk-pr
date: 2026-05-26
type: correction
severity: medium
---

PR description must be updated immediately after CI goes green, not deferred.

**What happened:** CI passed but the test-plan checkbox for CI was left unchecked; PR description was not synced post-green.

**Root cause:** Agent treated description sync as a push-time-only action and did not re-run it after CI completed.

**Suggested fix:** Add an explicit step after the CI-green exit: check off CI test-plan items and sync any drifted description content before proceeding to `gh pr ready`.
