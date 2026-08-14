---
class: principle
source: learnings/skills/pr-merge/2026-08-14_stack-async-classifier-block.md
date: 2026-08-14
---

## Server-side stack membership forces async REST merge

GitHub's org-level stacked-PRs feature flags PRs as "part of a stack" server-side,
independent of local `gh stack` extension state. `gh pr merge` fails with a
GraphQL error directing the caller to the async REST merge API. `gh stack view`
returning no local stack does not clear this flag.

**Principle:** Server-side platform state may diverge from local CLI tooling state.
When a merge command fails due to a server-side feature, the skill must document a
fallback chain rather than hard-stopping. The classifier denial of the REST
fallback is a separate concern (covered by the existing classifier HARD RULE).

**Fallback chain landed in Step 6:**
1. `gh pr merge --auto`
2. `gh stack merge {number} --yes --merge-method {method}`
3. Surface `gh api repos/{owner}/{repo}/pulls/{number}/merge --method PUT` for
   manual user execution

**Landed in:** Step 6 — server-side stack flag bullet.
