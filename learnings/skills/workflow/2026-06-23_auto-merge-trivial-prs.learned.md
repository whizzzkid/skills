---
skill: wk-workflow
date: 2026-06-23
type: correction
severity: medium
---

For trivial PRs (<25 lines of net diff), enable auto-merge instead of polling CI.

**What happened:** After creating a PR with a 9-line diff (4 deletions, 5 insertions), the workflow entered the standard CI polling loop and waited for all checks to complete before marking ready — adding unnecessary latency for a change with no meaningful review risk.

**Root cause:** The workflow's Phase 6 CI Fix Loop and Phase 5 ready-marking sequence treat all PRs uniformly regardless of diff size. For trivial, low-risk changes (removing a dead target, updating counts), the overhead of polling, self-review, and a manual `gh pr ready` is disproportionate.

**Suggested fix:** In Phase 5/6, after `gh pr create`, measure `git diff $BASE...HEAD --shortstat` line count. When net diff is <25 lines AND adversarial review returned `clear` with no findings, skip the polling loop and instead: (1) mark the PR ready immediately, (2) run `gh pr merge --auto --squash` so it merges as soon as required checks pass. Document the threshold in the PR body so reviewers understand the auto-merge intent.
