---
class: principle
skill: wk-adversarial-review
date: 2026-06-16
---

**Rule:** Before flagging that a file written in one CI step won't reach a later
step, grep the pipeline templates for `artifact_upload`/`artifact_download` (or
`artifacts: upload`/`download`) matching that path. Confirmed upload+download
resolves the concern → do not surface it.

**Why:** Script-level file I/O that crosses CI step boundaries always has a
pipeline artifact contract. Reviewing only the application source misses the
orchestration layer, producing false `question`/`blocker` findings about
persistence that the pipeline already guarantees.

**Where:** Step 5 — Specialized checks (cross-step file persistence).
