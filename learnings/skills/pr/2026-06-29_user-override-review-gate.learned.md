---
skill: wk-pr
date: 2026-06-29
type: correction
severity: medium
---

User "no review" instruction must be honored before the review Skill call fires

**What happened:** User said upfront that no adversarial review was needed. Agent proceeded to invoke wk-pr, which attempted to run base detection and triggered a permission prompt the user had to deny.

**Root cause:** Agent treated the user's instruction as context to note rather than an immediate waiver. Per using-superpowers, user instructions override skill hard rules — "no review needed" should suppress the adversarial-review Skill call before it is dispatched, not after the user denies the prompt.

**Suggested fix:** At the top of wk-pr, before the adversarial-review gate in Step 2, check whether the user's current-session instruction waives the review. If waived, skip the Skill call entirely and continue from Step 2's `gh pr create`. Never rely on the user denying a permission prompt to enforce their own instruction.
