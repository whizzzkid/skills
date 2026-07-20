---
class: principle
---

**Rule:** In automated-review-feedback triage, default to fixing any bot finding
whose premise is correct and whose fix is small (<~10 lines) in-round. Reserve
"defer" for findings that are genuinely large, contested, or outside the PR's
stated scope. When unsure between fix and defer on a small correct finding, fix
it. Present triage as "fixing these, deferring X because Y" — not "recommend
fixing one, defer the rest".

**Why:** Deferring a small correct finding is not the cheap/safe default — it
forces a follow-up review round the reviewer must re-approve, which is costlier
than an in-round fix.

**Where:** wk-pr, Step 4 (Address automated review feedback).
