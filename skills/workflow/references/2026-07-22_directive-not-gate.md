---
date: 2026-07-22
slug: directive-not-gate
class: principle
---

- **Rule:** A terminal directive ("mark ready?", "merge?", "push?") is an execute-now signal even when phrased as a question. Query current state (CI, approvals) and act; do not wait or poll on a condition unless explicitly told "once CI finishes" or similar.
- **Why:** Question syntax on an imperative reads as permission-seeking; misreading it as conditional stalls the turn on a barrier the user did not impose.
- **Where:** `Autonomy Rules` table row in `wk-workflow` SKILL.md.
