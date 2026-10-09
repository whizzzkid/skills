# Patch-Replay Strategy (`$AHEAD ≥ 5`)

Goal: land the branch's **net diff** on the new base as a single integration commit,
preserving traceability to the original commits.

```bash
# 1. Snapshot the net diff against the OLD base (the merge-base, not the
#    new tip — patch-replay is "what did this branch change", not "what
#    happened on main since this branch forked").
OLD_BASE=$(git merge-base HEAD "$BASE_REF")
git diff "$OLD_BASE..HEAD" > /tmp/pr-update-$$.patch

# 2. Capture the original commit log for the integration commit body
git log --reverse --format='- %h %s' "$OLD_BASE..HEAD" > /tmp/pr-update-$$.log

# 3. Reset the branch to the new base
git reset --hard "$BASE_REF"

# 4. Apply the patch
if ! git apply --3way /tmp/pr-update-$$.patch; then
  # Conflicts — fall into the resolution loop with patch context
  echo "Patch did not apply cleanly. Resolving conflicts..."
fi
```

After patch application (clean or post-conflict-resolution), produce **one** integration
commit naming the squashed subject and listing the original commits in the body for
git-log traceability:

```bash
git add -A
git commit -S -m "$(cat <<EOF
<conventional-subject>: <emoji> <one-line summary of the net change>

Squashed via wk-pr-update onto $BASE @ $(git rev-parse --short "$BASE_REF").

Original commits:
$(cat /tmp/pr-update-$$.log)

Co-Authored-By: <agent>
EOF
)"
```

Commit subject MUST follow `wk-commit`'s conventional format with a single emoji
classifier. Clear branch theme → use it; mixed → use 🤖 (the "no single emoji fits"
fallback).

Patch-replay rewrites the branch to one commit — **the original commits are lost from
its git log**, living only in the integration commit's body (the accepted cost at ≥5
commits of not picking "force rebase").
