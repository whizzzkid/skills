---
skill: wk-adversarial-review
date: 2026-07-31
type: pattern
severity: medium
verified-against-source: yes
---

Validate canonical numeric text before converting it to a number.

**What happened:** A calendar-version parser accepted a leading-zero component because its broad text pattern
matched first and numeric conversion then erased the non-canonical representation before date validation.

**Root cause:** Driving the parser with a leading-zero input confirmed that text-to-number conversion normalized the
invalid spelling into a valid numeric date.

**Suggested fix:** For version, identifier, and serialized-number parsers, encode canonical spelling constraints in
the pre-conversion grammar and add a regression case for representations that normalize to the same number.
