---
skill: wk-commit
class: one-off
type: mechanics
---

# CI-fix squash offer — detection commands and ask template

Mechanics for the `Post-CI-Fix Squash Offer` section. The rules (never
auto-squash, never squash across user-authored commits, confirm the force-push)
live in `SKILL.md`; only the commands live here.

## Detection

Count commits ahead of base whose subject matches `^fix(\(ci\))?:`, and the net
diff across just those commits:

```bash
BASE=$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null || echo "main")
N=$(git log --oneline "$(git merge-base HEAD "$BASE")..HEAD" \
    --grep '^fix(\(ci\))\?:' | wc -l | tr -d ' ')
LINES=$(git diff "$(git merge-base HEAD "$BASE")..HEAD" \
    -- $(git log --name-only --pretty=format: "$(git merge-base HEAD "$BASE")..HEAD" \
    --grep '^fix(\(ci\))\?:' | sort -u) | wc -l | tr -d ' ')
```

## Ask template

Fires only when `N >= 3 && LINES < 50`:

> "The branch has {N} `fix(ci):` commits whose net diff is {LINES}
> lines. Want me to squash them into a single
> `fix(ci): <emoji> <what-actually-shipped>` commit before marking the
> PR ready? (a) yes  (b) keep separate"
