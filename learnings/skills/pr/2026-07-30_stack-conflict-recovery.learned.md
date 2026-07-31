---
skill: wk-pr
date: 2026-07-30
type: gap
severity: high
verified-against-source: yes
---

Recover conflicts across an existing pull request stack with the stack CLI, not independent
branch rebases.

**What happened:** A linked stack needed rebasing after its trunk moved. Importing the remote stack,
running the cascading rebase, and pushing every rewritten layer preserved the dependency order.
Rewritten commit IDs then required current-head CI verification and pull request description sync.

**Root cause:** The pull request workflow explains how to create a stack but does not prescribe a
conflict-recovery sequence for an existing stack. Rebasing branches independently can sever the
parent chain or push only part of the rewritten stack. The GitHub-owned extension documents that
`gh stack rebase` works from trunk upward and supports `--continue` and `--abort`.

**Suggested fix:** Add an existing-stack recovery path: run
`gh stack checkout <top-pr-url>`, confirm a clean tree and snapshot every branch/base/head, then run
`gh stack rebase`. Resolve one conflicted layer at a time, stage it, and continue with
`gh stack rebase --continue`; use `--abort` if the resolution is unsafe. Verify ancestry and the
full test gate before `gh stack push`, then verify every remote head, current-head CI run, review
thread, and commit ID cited in each pull request body.
