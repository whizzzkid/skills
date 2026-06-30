---
class: principle
---

**Rule:** The "push after every commit" mandate applies once a branch has an
upstream or an open PR. The *first* push of a brand-new remote branch with no
open PR is gated on explicit user confirmation.

**Why:** Pushing a new branch with no PR creates an orphaned remote branch —
visible to teammates, carrying no PR context, harder to reason about. The push
mandate exists to keep work visible, not to scatter context-free branches.

**Where:** `## Pushing`, second bullet. Detect via `git rev-parse
--abbrev-ref --symbolic-full-name @{u}` (non-zero exit = no upstream = first
push) combined with `gh pr view 2>/dev/null` returning no open PR.
