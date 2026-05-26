---
class: principle
date: 2026-05-26
source: learnings/skills/wk-pr/2026-05-26_self-review-mandatory-after-ci.md
severity: high
---

- **Rule:** Self-review is mandatory after CI green; there is no size, simplicity, or scope exemption. If the parallel Step 3 self-review was skipped for any reason, Step 4 must invoke `wk-self-review` before proceeding. Silent skip is forbidden; skipping requires explicit user instruction in the current session.
- **Why:** Agent judged a diff "obvious" and skipped self-review without surfacing the decision; reviewers lost the design-context layer the self-review provides.
- **Where:** Step 4 item 3 — HARD RULE "self-review is mandatory after CI green."
