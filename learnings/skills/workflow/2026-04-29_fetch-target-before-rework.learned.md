---
skill: wk-workflow
date: 2026-04-29
type: gap
severity: medium
---

Reworked a PR's branch without first fetching the latest tip of its base
branch, leaving the rework based on stale state and producing avoidable
merge conflicts.

**What happened:** User asked to rework the PR's architecture and merge
main. I fetched main but did not fetch the PR's actual base branch
(`feat/{repo}-status-comment-part-3`) before starting the
restructure. The base had advanced 3 commits since the prior rebase.
After committing and pushing the rework, GitHub immediately reported
`CONFLICTING` and the user had to ask "why am I still seeing conflicts"
before I noticed. A second rebase + force-push was required, doubling
the work.

**Root cause:** The workflow's "merge latest main" step (Phase 6 / CI
fix loop and the PR-update flow) treats the default branch as the only
upstream that matters. When the PR is stacked, the *actual* base is a
non-default branch that mutates independently of main and can advance
while the agent works. The skill never says "fetch the PR's
`baseRefName` and rebase onto it before any rework."

**Suggested fix:** Add a step to wk-workflow that fires whenever the
agent is about to rework a PR (force-push, big restructure, content
rewrite):

1. `gh pr view <n> --json baseRefName` to get the actual base — never
   assume `main`.
2. `git fetch origin <baseRefName> main` (both, in case main is also
   relevant for stacked PRs).
3. Compare local merge-base against `origin/<baseRefName>`. If it
   advanced, rebase or cherry-pick onto the new tip *before* starting
   the rework.
4. Only after that, do the rework, commit, and push.

Skipping step 1-3 produces conflicts that are 100% predictable from
remote state and 100% avoidable with a 5-second fetch. The cost of
fetching is trivial; the cost of pushing a rework that immediately
conflicts is a forced second cycle plus user-visible churn.
