---
class: principle
---

**Rule** — Before checkout, detect a PR that auto-closed because its base was
merged + deleted (`state: CLOSED` + empty `git ls-remote --heads origin <base>`).
Do not `gh pr reopen` or `gh pr edit --base` — both fail on such a PR. Recover by
`git rebase --onto origin/<default> <last-base-commit> HEAD`, force-push, and open
a NEW superseding PR to the default branch, cross-linked both ways.

**Why** — GitHub forbids both reopen (`Could not open the pull request`) and base
change (`GraphQL: Cannot change the base branch of a closed pull request`) once the
original base ref no longer exists. No in-place revive path exists. The rebase
re-parents only the PR's own commits, so a clean-content revival is conflict-free.

**Where** — wk-pr-takeover Step 3 (Revive precheck), before any branch checkout.
