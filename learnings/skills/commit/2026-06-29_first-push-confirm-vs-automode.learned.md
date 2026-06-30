---
skill: wk-commit
date: 2026-06-29
type: correction
severity: medium
---

First-push-of-new-branch confirmation fired despite auto mode + an explicit create-and-track directive; user pushed back with "why do you keep confirming?"

**What happened:** After committing, the "first push of a brand-new branch with no PR → confirm intent first" rule triggered a permission prompt before `git push`. The original user prompt had already said to create the workflow AND "create a ticket to track this work" — an unambiguous directive to publish a PR-tracked change. Asking to confirm the push re-litigated approval the directive already gave.

**Root cause:** The first-push confirm rule reads as unconditional, but it should yield when (a) auto mode is active and (b) the session's originating directive clearly intends a published/tracked PR. The branch-with-no-upstream signal alone does not mean "unclear intent."

**Suggested fix:** Scope the first-push confirm to genuinely ambiguous cases. When auto mode is on and the user's own prompt already authorizes a tracked PR (e.g. "create a ticket to track this", "open a PR", "ship X"), skip the confirm and push — the new-branch state is expected, not a surprise.
