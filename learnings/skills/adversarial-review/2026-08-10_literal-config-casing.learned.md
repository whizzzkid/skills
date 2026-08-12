---
skill: wk-adversarial-review
date: 2026-08-10
type: pattern
severity: medium
verified-against-source: yes
---

Validate case-sensitive configuration suffixes against authoritative syntax, even when supplied verbatim.

**What happened:** Review detected inconsistent casing between two related literal identifiers; the authoritative
documentation confirmed only the lowercase suffix form.

**Root cause:** A requested configuration value was treated as authoritative without validating the case-sensitive
suffix against the consumer's documented syntax.

**Suggested fix:** For literal configuration identifiers with structured suffixes, compare sibling entries and check
the current primary documentation before publishing.
