---
class: principle
---

# No key at first development intent → offer a ticket before the first commit

**Rule** — run Stage 1 at the moment a task turns into code, including an investigation that pivots to a fix. No key
→ ask once whether a ticket exists or offer to create one (project, priority, sprint) before the first commit. A
requested priority missing from the project's scheme → use the highest allowed value and say so.

**Why** — an incident investigation became a fix and a PR with no ticket in context. The installed "no key → ask once"
rule never fired because Stage 1 was never run at the pivot, so the lifecycle was silently skipped and the user had to
request a ticket afterwards. Re-violation of an installed rule (missed trigger) → escalated one rung (baseline →
`**Important:**`) and bound to the first-development-intent trigger.

**Where** — `SKILL.md` → Stage 1 (*Important — no key at first development intent*) and Manual ticket operations
(priority fallback).
