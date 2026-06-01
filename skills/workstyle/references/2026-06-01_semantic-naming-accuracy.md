---
class: principle
skill: wk-workstyle
date: 2026-06-01
severity: high
---

- **Rule:** Audit every introduced identifier for semantic accuracy —
  the name must describe what the value *means*, not just what it
  *contains* — as a required gate, not advisory.
- **Why:** A name can pass casing/length/abbreviation rules and still
  lie (a `minor + info` bucket named `nitpicks`); a human reviewer
  caught the inaccurate name that the authoring pass missed.
- **Where:** Step 1 → Universal rules → Naming (new bullet, framed as a
  required gate).
