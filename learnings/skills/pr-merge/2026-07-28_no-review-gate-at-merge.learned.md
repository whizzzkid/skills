---
skill: wk-pr-merge
date: 2026-07-28
type: correction
severity: medium
verified-against-source: yes
---

Step 5.5 must not require its own adversarial-review verdict pinned to current HEAD.

**What happened:** A PR (#NNN) was fully green on all required CI checks with every
reviewer/bot thread resolved. The last commit on the branch was a one-line comment typo
fix that an automated reviewer had itself requested. Step 5.5 treats "the recorded
clearance predates current HEAD" as a hard block, so that typo commit invalidated the
existing clearance and demanded a brand-new full adversarial review before the merge
could proceed. The user rejected the gate outright and waived it.

**Root cause:** The gate is keyed on SHA equality (verdict SHA == HEAD SHA) rather than
on whether unreviewed *logic* exists. Every review-response commit advances HEAD, so the
fix loop is self-perpetuating: review → fix → clearance invalid → review. The merge was
also miscast as the review trigger; the real trigger is "the work is complete at our end
and ready for agent/human review", which happens once, before publishing.

**Suggested fix:** Replace the per-HEAD verdict gate in Step 5.5 with:

- Merge proceeds on required CI green + reviewer/bot threads resolved.
- A review is required only when **no** review has run on this body of work at all.
- Commits that only respond to already-surfaced findings (typo fixes, reworded comments,
  applying a reviewer's own suggestion) do **not** invalidate an existing clearance.
- Re-review only when genuinely new, unreviewed logic lands after the clearance.
- Keep the explicit-user-waiver path, but it should now be rarely needed.

Same principle applies to `wk-pr`'s adversarial-review hard rule — see the parallel
learning under `pr/`.
