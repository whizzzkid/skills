---
class: principle
---

**Rule:** When base integration during sync conflicts because the base branch
advanced (an upstream PR merged), rebase the branch's own commits onto the new
base before resuming the workflow. The new base is authoritative for
overlapping hunks; resolve each conflict against it during replay:

```bash
git fetch origin "$BASE_BRANCH"
git rebase --onto "origin/$BASE_BRANCH" "$(git merge-base HEAD "origin/$BASE_BRANCH")"
```

Re-verify, resume only on a clean tree, and push the rewritten branch with
`git push --force-with-lease` (scoped exception to the never-force-push rule) —
never bare `git push -f`. Never triage, fix, or push on a conflicted or
unmerged tree.

**Why:** A conflict from an advanced base is not a "which side wins" judgment —
the merged upstream change is current truth; the branch hunk is stale. Rebasing
onto the new base keeps a linear history and lets each branch commit replay
against the authoritative base. Proceeding with triage on a conflicted tree
pushes a broken merge and resolves threads against code that no longer matches
the base. `--force-with-lease` updates the rewritten branch without clobbering
remote-only commits — a bare force-push can silently drop a collaborator's work.

**Where:** Step 2 (Sync Branch); Hard Rule 4 exception; Step 8 push path.
