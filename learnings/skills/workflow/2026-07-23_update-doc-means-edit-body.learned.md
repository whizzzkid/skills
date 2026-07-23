---
skill: wk-workflow
date: 2026-07-23
type: correction
severity: low
---

"Update the doc/plan to mark items done" means editing the artifact body, not commenting.

**What happened:** Asked to mark plan items done, the agent posted a PR comment; the user re-asked, wanting the doc content itself changed.

**Root cause:** Ambiguity resolved toward the cheaper action (comment) instead of the artifact edit the user meant.

**Suggested fix:** Treat "update/mark in the plan/doc" as an edit to the source file's body; use a comment only when the user explicitly asks to comment.
