---
class: principle
date: 2026-05-22
source: learnings/skills/adversarial-review/2026-05-22_cross-doc-synonym-miss.md
---

- **Rule:** When sweeping for a removed term, generate a variant set (original, Title Case, sentence case, lower case, space-to-dash, alternate phrasings) and grep each; explicitly include spec-table row labels and validator/plugin SKILL files as sweep targets.
- **Why:** Exact-string grep of the removed token misses casing variants and table-row labels; bots flagged stale-doc sites that prose-only greps did not see.
- **Where:** Step 2.8 "Cross-doc enumeration sync" — appended synonym + casing sweep block with table-row grep snippet and named sweep targets.
