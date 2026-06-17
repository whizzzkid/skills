---
class: principle
---

**Rule:** When base integration during sync conflicts because the base branch
advanced (an upstream PR merged), resolve every conflict against the new base
first, complete the merge, and re-verify before resuming the workflow. The new
base is authoritative for overlapping hunks. Never triage comments, apply
fixes, or push on a conflicted or unmerged tree.

**Why:** A conflict from an advanced base is not a "which side wins" judgment —
the merged upstream change is the current truth; the branch hunk is stale.
Proceeding with triage on a conflicted tree pushes a broken merge and resolves
threads against code that no longer matches the base.

**Where:** Step 2 (Sync Branch).
