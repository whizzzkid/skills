---
skill: wk-commit
date: 2026-06-29
type: correction
severity: medium
---

Push on new branch without confirming PR intent

**What happened:** Agent committed and pushed to a new remote branch immediately per wk-commit's "push after every commit" default, without confirming whether the user intended to open a PR.

**Root cause:** wk-commit's push mandate has no gate for the case where the branch is new on the remote and no PR exists yet. Pushing creates an orphaned remote branch — visible to teammates, no PR context, harder to reason about.

**Suggested fix:** When `gh pr view 2>/dev/null` returns no open PR and `git push` would create a new remote branch, pause and confirm push intent before pushing. The push mandate applies to branches with an existing PR; for brand-new remote branches, confirm first.
