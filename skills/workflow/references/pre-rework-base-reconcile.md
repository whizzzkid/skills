---
class: principle
date: 2026-06-25
skill: wk-workflow
severity: medium
---

- **Rule:** Before reworking a PR branch (force-push, restructure, rewrite, big
  rebase, scope change), fetch and reconcile against the PR's actual base and the
  default branch; delegate to `wk-pr-update` when the base advanced.
- **Where:** Phase 5 Pre-rework fetch. Concrete recipe relocated here to keep
  `SKILL.md` under the body-size ceiling.

```bash
PR_NUM=$(gh pr view --json number --jq .number)
BASE=$(gh pr view "$PR_NUM" --json baseRefName --jq .baseRefName)
DEFAULT=$(git symbolic-ref refs/remotes/origin/HEAD --short | sed 's@^origin/@@')

git fetch origin "$BASE" "$DEFAULT" --quiet

LOCAL_MB=$(git merge-base HEAD "origin/$BASE")
REMOTE_TIP=$(git rev-parse "origin/$BASE")
if [ "$LOCAL_MB" != "$REMOTE_TIP" ]; then
  Skill(wk-pr-update, args="$BASE")
fi
```
