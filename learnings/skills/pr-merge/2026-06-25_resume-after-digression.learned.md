---
skill: wk-pr-merge
date: 2026-06-25
type: correction
severity: medium
---

Resume all pending post-merge steps after answering a user digression question.

**What happened:** User asked an unrelated question mid-workflow (during Step 9 retro / wk-learn). Agent answered the question then stopped, requiring the user to explicitly prompt "did you forget running the rest of the workflow?" before Steps 9-10 completed.

**Root cause:** The skill did not include a guard to detect in-progress workflow state and resume from the interrupted step. A user question during Step 9/10 was treated as a session end.

**Suggested fix:** After answering any user question during Steps 7-10, immediately note the pending step and resume from where the workflow was interrupted — never treat a user question as implicit workflow termination.
