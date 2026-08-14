---
class: principle
severity: high
escalation: baseline → Important (rung 2)
source: learnings/skills/workflow/2026-08-14_run-linter-before-push.md
---

## Local lint before every push — re-violation escalation

Rule existed at baseline (installed 2026-06-16): "Project linter/type checker
passes" and "Full pre-push gate passes before any git push." Agent pushed code
failing linter checks multiple times, relying on CI instead of running locally.

Escalated to **Important** — rung 2 on the ladder.

**Landed in:** `SKILL.md` Phase 3 → "Important — local lint before every push" bullet.
