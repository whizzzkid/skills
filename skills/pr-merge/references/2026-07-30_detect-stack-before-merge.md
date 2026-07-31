---
class: principle
---

# Detect stack membership before choosing merge mechanics

- **Rule:** Probe stack metadata before single-PR gates. Gate every included PR,
  select a ruleset-allowed method, merge the set atomically, then verify every
  member and the target branch report the stack merge commit.
- **Why:** A workflow starting from one PR cannot distinguish an independent PR
  from one layer of a stack; sequential handling forfeits the all-or-nothing
  property and can leave a partially merged stack.
- **Verification:** The target skill only detected child PRs immediately before
  deleting one branch. Installed extension help confirms machine-readable stack
  metadata, atomic merge, non-interactive confirmation, and explicit merge-method
  selection.
- **Rejected:** Do not silently fall back to sequential merges when the installed
  official extension lacks the required command or flags. Stop and request
  upgrade approval.
- **Where:** [`wk-pr-merge`](../README.md), between PR resolution and the
  single-PR gate sequence.
