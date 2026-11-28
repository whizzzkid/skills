---
skill: wk-gh
date: 2026-11-28
type: surprise
severity: medium
verified-against-source: no
---

After a GitHub stack merges its lower layers, the remaining layer's branch is rewritten onto the default branch.

**What happened:** While a fix was being committed locally on the top layer, the user merged the lower layers of a
GitHub stack. The top layer's remote branch was replaced by a linear rebase onto the default branch, with the local
merge commits gone and the base changed to the default branch. The next regular push was rejected as
non-fast-forward.

**Root cause:** (unverified — inferred from symptom) Merging lower layers of a stack makes the stack tooling rebase
and retarget the remaining layers.

**Suggested fix:**
- Fetch first. If the remote branch's tree equals the local tree before the new commit, cherry-pick only the new
  commit onto the remote head, push it as a fast-forward, and repoint the local branch.
- Never merge a stale local history back in, and never force-push over the rewritten branch.
- Once a repo uses GitHub stacks, prefer the stack tool's own sync over merge-based propagation.
