---
class: principle
---

# The approve gate requires the claim ledger and Phase 2 to be complete

**Rule**

- Approve gate preconditions include: every `pr_claims` item marked Confirmed/Refuted/Unverified (each Refuted one
  commented) and Phase 2 completed (threads classified, every bot finding routed through Phase 3).
- Check each precondition against its recorded artifact, never recall; a skipped phase leaves no artifact, so the gate
  fails closed.
- `light` mode's time box shortens phases, never skips one — only the Phase 3 dispatch is deferred. Escalated one rung
  (baseline → `**Important:**`) as a re-violation of the installed "Phases 1, 2, 4, 5 in full" rule.
- Post-Completion `wk-learn` runs on every run, approved or pending. Escalated one rung (baseline → `**Important:**`).
- "Fixed"/"addressed" claims are verified by reading the cited file at the PR head; a compare range spanning a base
  merge carries base changes, so a changed-file list never proves a fix.

**Why**

- A `light` + `approve` run approved after tests and spot checks, skipping claim marking, the bot-comment pass, and
  post-completion capture. The gate listed only concern/verdict/check/author conditions, so nothing blocked it, and an
  approval cannot be withdrawn. A re-run found no refuted claims — the outcome was lucky, the process was not.

**Rejected**

- Making `wk-learn` a gate precondition: capture runs after posting and does not bear on whether the approval is
  sound; escalation of the Post-Completion line covers the skip instead.

**Where** — `SKILL.md` → Approve Flag → Approve gate; Review Modes → `light`; Phase 1 → Claims; Post-Completion.
