---
class: principle
---

# Required-check state is re-queried at the approve gate

**Rule**

- The approve gate's "no failing required check" precondition reads live state, never the Phase 1 snapshot.
- Query `gh pr view --json headRefOid,statusCheckRollup` in the same step as the head recheck; the rollup's
  `headRefOid` must equal `PR_HEAD` (a lagging rollup describes the prior commit).
- Judge required-ness from the branch's required-status sources per `wk-gh` (rulesets + classic protection), not from
  the rollup alone — the rollup lists every check, required or not.
- Apply the `wk-gh` rollup union rules (`.status`/`.conclusion` and `.state`).
- Pending or not-yet-posted required check → not failing (gate semantics unchanged), but named in the terminal so the
  user knows the approval landed ahead of it.
- Submit path re-reads the rollup alongside its own head recheck; a required check that turned red → stay pending.

**Why**

- CI is time-varying, unlike the claim ledger or Phase 2 queue outcomes, which are fixed once recorded. A check
  pending at Phase 1 was green by Phase 5; judged on the snapshot the review would have been held pending. The
  inverse — green at Phase 1, red at Phase 5 — would approve over a failure, which is irreversible.
- The suggestion to treat pending as "not failing" matches the installed gate wording; it is kept, not relaxed. Making
  pending a hard block was not adopted (outside the report's evidence; would hold most reviews of in-flight PRs).

**Where**

`skills/pr-review/SKILL.md` → Approve Flag → gate sub-bullets; `references/posting-pending-review.md` → "Submit as
approval".
