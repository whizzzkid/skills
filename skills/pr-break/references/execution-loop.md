# Stage 7: Execution Loop

Execute only on explicit approval. Auto mode default: save plan to file and stop.

## Child Branch Naming

Every child branch reuses the original PR's branch name with a `-part-N` suffix, where `N` is the child's stack position starting at **1**:

```
<original-branch>          # parent / source
<original-branch>-part-1   # first child (cut from $BASE_BRANCH)
<original-branch>-part-2   # second child (cut from -part-1)
<original-branch>-part-3   # third child (cut from -part-2)
...
```

Original branch already ends in `-part-N` (re-splitting an already-split PR) → append onto the **leaf** name; do not double-suffix. `feat/foo-part-2` becoming a 2-child split produces `feat/foo-part-2-part-1` and `feat/foo-part-2-part-2`, not `feat/foo-part-1` (which would collide with a sibling).

Validate the names before cutting branches:

```bash
ORIG_BRANCH=$(gh pr view "$PR_NUM" --json headRefName --jq .headRefName)
for n in $(seq 1 "$N"); do
  CHILD="$ORIG_BRANCH-part-$n"
  if git show-ref --verify --quiet "refs/heads/$CHILD" \
     || git ls-remote --exit-code --heads origin "$CHILD" >/dev/null 2>&1; then
    echo "Branch $CHILD already exists locally or on origin; aborting."
    exit 1
  fi
done
```

Name collisions abort the run rather than silently overwriting — re-running `wk-pr-break` after a partial failure must not clobber the prior attempt's branches.

## Per-Child Execution

For each child, in stack order:

1. Cut the child branch from its parent (the previous child's branch, or `$BASE_BRANCH` for the first child).
2. Apply the child's diff. Source it from the original PR's branch via `git checkout <orig> -- <paths>` for whole files, or `git apply` of a pre-prepared patch for partial files. The original PR's branch stays unchanged until all children are opened.
3. Run the project's test command (Phase 3 of `wk-workflow`); fails → stop. Invariant 2 was violated by the seam, not by execution.
4. Invoke `wk-commit` for the child's commit (signed, conventional, single emoji).
5. Invoke `wk-pr` to open the child as a draft PR with the description populated from Stage 4.
6. Wait for CI to go green via the standard `wk-workflow` Phase 6 loop.

After all children are open, update the original PR's description to reference the stack ("This PR is being shipped as a stack: #child1, #child2, ..."). Do **not** close the original PR until the stack lands — it remains the source of truth for the full diff during review.

Child fails CI in a way suggesting the seam is wrong (not a flaky test, not an infra blip) → pause and ask the user before patching the child. The failure may indicate the plan needs re-cutting.
