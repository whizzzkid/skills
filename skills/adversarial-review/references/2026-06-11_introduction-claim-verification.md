---
class: principle
date: 2026-06-11
skill: wk-adversarial-review
---

- **Rule:** Before rating a "newly introduced" behavioral change a blocker,
  grep the removed (`-`) lines of the same hunk for the flag/value. If the
  removed block already carried it, the claim is a false positive — dismiss.
- **Why:** A subagent reasoning only on `+` lines mis-claims a relocated
  flag as new; "before" behavior lives in the `-` lines. Burns a fix cycle.
- **Where:** Step 3 subagent bullets — new "Introduction-claim verification",
  sibling to "Relocation-aware".
