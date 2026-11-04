---
class: principle
---

# One command per Bash call — escalated to Very important (rung 3)

- **Rule:** Before sending a Bash call, split any `&&`, `||`, or `;` between commands. Stage, commit, and push are three
  calls; an edit and its verify grep are two.
- **Classification:** `already-covered` re-violation. The rule shipped at `**Important:**` on 2026-10-14, before this
  report, yet across a long session the agent chained stage + commit + push and paired edits with verify greps. Never
  flagged live, so the habit stuck. Escalated rung 2 → rung 3 (`**Very important:**`) and given a concrete pre-send
  check naming the commonest chains.
- **Rejected:** "Except where one command is the deliberate gate for the next" — that exemption covers almost every
  chain (each `&&` gates the next by construction), so it would relax the rule to nothing. Dependent commands already
  have their form: separate sequential calls.
- **Where:** [`wk-workflow`](../README.md) → Phase 2 → Code standards.
