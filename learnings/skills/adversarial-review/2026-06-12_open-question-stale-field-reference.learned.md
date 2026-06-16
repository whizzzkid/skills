---
skill: wk-adversarial-review
date: 2026-06-12
type: gap
severity: medium
---

Open-questions sections go stale when struct fields are removed or renamed.

**What happened:** A struct field was removed from the core contract and moved to an optional overlay struct. An open-questions section in the same doc still referenced the old field name directly (`Result#old_field`), creating a circular stale reference — the overlay note cited the open question, the open question referenced the removed field.

**Root cause:** Cross-doc enumeration sweeps focus on prose, bullet lists, and tables. Open-questions / decision-log sections are not treated as enumerated sets, so removed field names in them are missed.

**Suggested fix:** Treat Q&A / open-questions / decisions sections as first-class grep targets when a struct field is removed or renamed. After any `field removal` commit in a spec, grep the full doc for the old field path including in Q&A sections. Flag any hit as a stale-reference blocker.
