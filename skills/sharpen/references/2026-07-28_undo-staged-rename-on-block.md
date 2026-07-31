---
class: principle
---

# A blocked landing must undo its processed-state rename

- **Rule:** If a commit fails after staging a processed learning, unstage only
  its `.learned.md` path and move it back to the plain name; keep the fold paths
  staged.
- **Why:** The filename hook requires `.learned.md` inside the fold commit, so
  delaying the rename is impossible; blocked state requires an explicit undo.
- **Where:** `SKILL.md` Step 8 commit recovery and
  `references/commit-gate.md`.
- **Coverage:** The earlier distilled-not-landed rule named the desired state
  but not the reversal, so this is a partial fold rather than escalation.
- **Budget:** Body `24414 + 24 = 24438` bytes, leaving 138 bytes.
