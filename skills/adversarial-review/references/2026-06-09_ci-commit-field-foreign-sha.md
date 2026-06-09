---
class: principle
skill: wk-adversarial-review
date: 2026-06-09
severity: high
---

- **Rule:** When the diff changes a `commit` field in a CI trigger payload,
  flag `blocker` if the value comes from a foreign-repo SHA env var
  (typically prefixed `REVIEW_`, `TARGET_`, `SOURCE_`).
- **Why:** The `commit` field names the pipeline repo's SHA; a foreign repo's
  target SHA does not exist there, so the build fails at clone. The two uses
  look identical in the diff but are semantically opposite.
- **Where:** Sweep 2.28 (CI-payload commit-field foreign-SHA check).
