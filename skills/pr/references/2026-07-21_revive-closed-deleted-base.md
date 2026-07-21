---
class: principle
---

**Rule** — When asked to revive a PR that auto-closed because its base was
squash-merged + deleted, do not `gh pr reopen` or `gh pr edit --base` (both fail).
Rebase the delta onto the default branch and `gh pr create` a fresh PR that
supersedes the closed one, cross-linked.

**Why** — GitHub refuses to reopen a PR whose base ref no longer exists and
forbids retargeting a closed PR. The only revive path is a new PR. Detection and
rebase mechanics live in wk-pr-takeover Step 3; wk-pr owns creating the fresh PR.

**Where** — wk-pr Step 2 gotcha "Superseded & closed PRs"; cross-refs
wk-pr-takeover Step 3.
