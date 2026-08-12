---
class: one-off
date: 2026-08-10
skill: wk-adversarial-review
---

# Case-sensitive configuration suffix validation

- **Scenario:** Review flagged inconsistent casing between related configuration
  identifiers; only the lowercase suffix form was authoritative.
- **Symptom:** A configuration value used an incorrect casing for a structured
  suffix, undetected because the value was accepted as-given without checking
  the consumer's documented syntax.
- **Fix:** For literal configuration identifiers with structured suffixes (file
  extensions, protocol identifiers, technology-specific tokens), compare sibling
  entries for consistency and check the consumer's primary documentation before
  publishing.
- **Why not promoted:** Sweep 2.4 covers assertive claims; sweep 2.8 covers
  symbol/docs sync. This is a narrow validation step for casing of structured
  suffixes. Body at ceiling (9 B headroom).
