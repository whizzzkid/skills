---
skill: wk-pr
date: 2026-05-26
type: correction
severity: high
---

Self-review is mandatory after CI passes; never skip it silently.

**What happened:** Agent declared the PR ready without invoking wk-self-review after CI went green.

**Root cause:** Agent judged the diff "obvious" and skipped self-review without presenting options or posting anything.

**Suggested fix:** wk-pr Step 4 must always invoke wk-self-review after CI green, with no size or simplicity exemption. Skipping requires explicit user instruction in that session.
