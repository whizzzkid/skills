---
skill: wk-pr-resolve
date: 2026-06-02
type: gap
severity: medium
---

wk-pr-resolve should auto-activate when the user mentions fixing a comment, addressing feedback, or "there's a description/comment issue" in a session where a PR was recently created or is the active work context.

**What happened:** User said "There's a description comment that needs fixing" after a PR was just created in the same session. The agent asked a clarifying question instead of immediately invoking wk-pr-resolve to fetch and triage the PR's comments.

**Root cause:** wk-pr-resolve's trigger description does not list implicit signals like "fix the comment", "there's an issue with the description", or "address the feedback" when a recent PR is in session context. The skill only activates on explicit phrases like "resolve PR comments" or "address review feedback".

**Suggested fix:** Add trigger patterns to wk-pr-resolve's skill description and using-superpowers routing: phrases like "fix a comment", "there's a [description/comment] issue", "address the feedback", or "fix this on the PR" should auto-activate wk-pr-resolve when a PR was created or actively worked on in the current session (detectable via `gh pr view` returning an open PR on the current branch).
