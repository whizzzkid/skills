---
class: principle
---

**Rule** — Worktree cleanup is the terminal, irreversible step. Run it only after
every pending question (the follow-up-filing offer, any user digression, any
accepted action) is answered and acted on. A pending reply blocks cleanup.

**Why** — Removing the worktree destroys the branch / PR / local context that
filing follow-ups or answering a question depends on. A question raised after
cleanup cannot be resolved — observed across repeated sessions where follow-ups
were stranded because the worktree was already gone.

**Where** — `wk-pr-merge` Step 10 (Clean up the current worktree).
