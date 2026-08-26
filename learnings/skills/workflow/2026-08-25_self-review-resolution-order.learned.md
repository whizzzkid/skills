---
skill: wk-workflow
date: 2026-08-25
type: correction
severity: low
verified-against-source: yes
---

Keep self-review threads open until full merge readiness.

**What happened:** The agent proposed resolving an ordinary self-review thread while a required review check was still running.

**Root cause:** The general unresolved-thread completion gate was applied before the review-resolution skill's more specific self-review ordering rule was read.

**Suggested fix:** When resuming a published pull request, load the review-resolution rules before acting on unresolved threads and resolve self-review threads only after required checks and external feedback are terminal.
