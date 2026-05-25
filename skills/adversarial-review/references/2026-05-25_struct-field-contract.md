---
class: principle
date: 2026-05-25
source: learnings/skills/wk-adversarial-review/2026-05-22_struct-field-contract-tests.md
---

- **Rule:** When the diff adds a field to a Struct/Record type, require a test that asserts the new field's concrete value (not a `respond_to?` / type-presence check). Transitive coverage through behavior tests passes today but allows a future refactor to drop or mis-populate the field silently.
- **Why:** Signature-widening sweep (2.7) catches function-parameter additions; struct-field additions look like data not behavior and slip past every mechanical sweep until a reviewer bot catches them.
- **Where:** New Step 2.19a "Struct/Record field-extension contract test" between 2.18 and 2.19; cross-referenced from 2.7 as the data-shape counterpart.
