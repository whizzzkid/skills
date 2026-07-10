---
class: principle
date: 2026-07-09
---

# A working-tree-clean rename can still leave the PR body stale

**Rule:** On any rename diff, a clean sweep 2.8 (working-tree grep) is not
proof the PR body is synced. Sweep 2.10 must grep the live body PROSE — not
just enum-like symbol lists — for every old literal name and any stale
count/enumeration the diff changed. Fix body-only drift via `gh pr edit`
(no commit; existing clearance stays valid).

**Why:** Sweep 2.8 greps the working tree, not the PR body; a rename fully
synced across source, tests, and docs can still leave old key names in prose
(narrative, a provisioning snippet) and a stale count, both invisible to a
code-only grep. Only the separate 2.10 sweep, which fetches the live body,
catches this — so 2.8 passing must never be read as "body clean too."

**Where:** Step 2 Mechanical Sweep Catalog, rows 2.8 and 2.10.
