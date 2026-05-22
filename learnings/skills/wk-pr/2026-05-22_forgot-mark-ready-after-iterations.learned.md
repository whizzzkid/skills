---
skill: wk-pr
date: 2026-05-22
type: correction
severity: high
---

Agent left PR as draft after completing all work; did not mark ready for review.

**What happened:** Multiple refactor rounds (dedup, annotation, Result struct) were completed after PR was created. Agent returned control without running the final adversarial review + `gh pr ready` per wk-pr Step 5. User caught it: "also why didn't you mark this ready for review? after everything was done?"

**Root cause:** Each refactor felt like a self-contained mini-task. The PR lifecycle Step 5 (mark ready) was lost in the iteration. Agent treated "pushed code" as "done" rather than "wk-pr lifecycle complete."

**Suggested fix:** After any push to an open draft PR, set an implicit goal: "mark ready when CI passes + adversarial-review clears." Never end a session/turn leaving the PR in draft unless CI is failing, a blocker was raised, or user explicitly said to pause.
