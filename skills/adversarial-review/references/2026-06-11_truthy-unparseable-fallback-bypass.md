---
class: principle
date: 2026-06-11
skill: wk-adversarial-review
severity: high
---

- **Rule:** Flag a two-store redundancy that branches on raw presence
  (`if raw`) but parses inside the branch — a non-nil unparseable value
  makes the parser return nil while the fallback `else` stays unreachable.
- **Why:** The redundancy is silently defeated for exactly the malformed
  input it existed to handle; high severity — data-loss / wrong-value bug.
- **Where:** Step 2 mechanical sweeps — new sweep 2.33. Correct shape:
  `parsed = raw && parse(raw); parsed || fallback`, plus a test stubbing
  primary→invalid and fallback→real.
