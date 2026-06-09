---
class: principle
skill: wk-adversarial-review
date: 2026-06-09
severity: medium
---

- **Rule:** When a doc/comment/instruction claims it will "warn", "notify",
  or "alert", confirm an explicit output step backs the claim.
- **Why:** A parenthetical "(warn the user)" with no imperative output block
  reads as optional and is omitted at runtime — the warning never fires.
- **Where:** Sweep 2.4 (Comment accuracy pass), "Warn-without-mechanism check".
