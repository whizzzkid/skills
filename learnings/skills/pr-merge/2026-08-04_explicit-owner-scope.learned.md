---
skill: wk-pr-merge
date: 2026-08-04
type: gap
severity: high
verified-against-source: yes
---

Explicitly targeted repositories must use their resolved owner throughout the merge flow.

**What happened:** The merge skill's command templates required the ambient organization variable,
but the user explicitly targeted a current repository owned by a different account.

**Root cause:** Repository identity and default organization scope were treated as interchangeable,
even though the GitHub routing rules allow an explicit repository to override the default scope.

**Suggested fix:** Resolve `{owner}/{repo}` from the PR at Step 1 and use that identity for every
read, child-retarget, merge, branch-deletion, and verification command; reserve the organization
variable only for searches without an explicit repository.
