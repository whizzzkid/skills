# Merge-Aware $AHEAD Recomputation

HEAD already contains a base-branch merge commit → raw `$AHEAD` overstates the
integration work (most commits already merged earlier). Recompute against the most
recent base-merge before applying the strategy heuristic:

```bash
LAST_BASE_MERGE=$(git log --merges --first-parent --grep="Merge .*$BASE" \
  --pretty=format:%H -1 2>/dev/null)
if [ -z "$LAST_BASE_MERGE" ]; then
  # Fallback: any merge whose second parent is on the base branch
  LAST_BASE_MERGE=$(git log --merges --first-parent --pretty=format:%H \
    | while read sha; do
        if git merge-base --is-ancestor "$sha^2" "$BASE_REF" 2>/dev/null; then
          echo "$sha"; break
        fi
      done)
fi
if [ -n "$LAST_BASE_MERGE" ]; then
  AHEAD=$(git rev-list --count "$LAST_BASE_MERGE..HEAD" --not "$BASE_REF")
  echo "Branch has prior merge from $BASE; $AHEAD new commits since."
fi
```

Recomputed `$AHEAD` small (`≤ 5`) AND `$BEHIND` small → prefer `git merge "$BASE_REF"`
over rebase or patch-replay; it's a merge-style branch, not rebase-style, and
patch-replay would squash already-reviewed commits.
