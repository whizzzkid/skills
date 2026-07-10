---
skill: wk-gh
date: 2026-07-10
type: correction
severity: medium
---

When `gh pr edit --base` fails with a transient GraphQL error, retarget via the REST API instead.

**What happened:** `gh pr edit <n> --base <branch>` returned
`GraphQL: Something went wrong while executing your query` repeatedly (with a
support reference id), leaving the base unchanged across several retries. The same
operation via REST succeeded on the first try:
`gh api -X PATCH repos/{owner}/{repo}/pulls/{n} -f base=<branch>`.

**Root cause:** `gh pr edit` drives the change through GitHub's GraphQL
`updatePullRequest` mutation, which intermittently 500s for base-branch changes
(notably right after reopening a PR or recreating branches). The REST
`PATCH /pulls/{n}` path does not go through that mutation and is more reliable.

**Suggested fix:** For base-branch retargets, prefer
`gh api -X PATCH repos/{owner}/{repo}/pulls/{n} -f base=<branch>` over
`gh pr edit --base`; fall back to REST automatically after one GraphQL failure
rather than retrying the GraphQL path.
