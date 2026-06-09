---
class: principle
skill: wk-adversarial-review
date: 2026-06-09
severity: high
---

- **Rule:** When the diff hardens one block in a group of structurally-
  parallel blocks, build a symmetry matrix and verify every guard / capture
  / assignment present in any block is present in ALL siblings.
- **Why:** Fixing one-of-N drives multi-round review loops — each round
  re-flags the identical class in the next sibling. The issue-class scan was
  scoped within the flagged block, not across analogous sibling blocks.
- **Where:** Sweep 2.27 (N-parallel-block symmetry sweep) + Step 6 Fix Loop
  cross-reference.
