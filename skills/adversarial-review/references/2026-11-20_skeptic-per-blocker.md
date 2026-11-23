---
class: principle
skill: wk-adversarial-review
date: 2026-11-20
---

# One skeptic per blocker

- **Rule:** After the adversarial subagent returns, dispatch one fresh skeptic per `blocker` finding that tries to
  refute it with a reproduction. A refuted blocker becomes a `question` (Contract 7).
- **Why:** In two sessions a fan-out review with one skeptic per finding downgraded an over-severe blocker, surfaced
  real mutation survivors, and exposed framework side effects (a missing frame, the snapshot cache) that request
  specs cannot see. A single reviewer's severity is a draft until something tries to break it.
- **Where:** `SKILL.md` → Step 3 (Fresh Adversarial Subagent). Source: session-7 and session-9 retrospects (What
  worked).
