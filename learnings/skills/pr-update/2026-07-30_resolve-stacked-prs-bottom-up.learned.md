---
skill: wk-pr-update
date: 2026-07-30
type: pattern
severity: high
verified-against-source: yes
---

Resolve stacked PR conflicts and review fixes from the base upward, treating every descendant's
base as moving state.

**What happened:** Review fixes landed on the first PR in a stack while later PRs were already open.
Each descendant needed the resolved parent tip integrated before its own findings and CI were
trustworthy. Stack tooling then linearized the descendant histories while the work was in progress.
The new remote tips had different commit IDs but identical trees, so recreating the merges or
re-solving conflicts would have duplicated work.

**Root cause:** A stacked branch is both an independent review unit and the base of another review
unit. Updating a parent changes the diff, conflict context, and CI basis of every descendant.
Meanwhile, stack tooling may rewrite descendant history after a push without changing the resulting
tree.

**Suggested fix:** Rediscover the live stack after each parent update. Work bottom-up: resolve and
verify the parent, integrate that exact tip into its direct child, audit every auto-merged
overlapping file for intent from both sides, then run the child's full gate before continuing.
After any stack-tool rewrite, fetch the live tip and use
`git diff --quiet <verified-tip> <live-tip>` to distinguish a history-only rewrite from a real
content change. Post review replies and resolve threads only after confirming the current remote
head. Before merging a parent, retarget its direct child to the parent's base and re-check the
child's mergeability and CI.
