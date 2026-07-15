---
class: principle
---

**Rule** — After the push lands and every reviewer thread is resolved on a draft
PR, run `gh pr ready {number}` without being asked — a fully-resolved draft is
review-ready.

**Why** — The resolution cycle's terminal state for a draft is "ready for review";
leaving it in draft forces the user to ask. Marking ready is the natural close of
Step 8, not a separate user request.

**Where** — wk-pr-resolve Step 8 "Push and Respond". Reclaimed the bytes by
deleting the Step 7 "Resolution rule" restatement (duplicated Hard Rule 3 +
line 104) and compressing the auto-mode sandbox note.
