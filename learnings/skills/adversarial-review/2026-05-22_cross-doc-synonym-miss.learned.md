---
skill: wk-adversarial-review
date: 2026-05-22
type: gap
severity: medium
---

Cross-doc enumeration sync (Step 2.8) missed variant phrasings of a removed term.

**What happened:** A validator rule was removed from a check file. Step 2.8 grep ran for the term that appeared in the validator (e.g. "clean-state instruction") and found no other docs using that exact phrase. Bot review subsequently flagged 4 stale-doc sites that used semantically equivalent but textually different phrases — "Clean-state output line", "clean-state output line", and a table-row label that described the same requirement.

**Root cause:** The cross-doc enumeration sweep searched for the exact removed token rather than the concept. Synonym variants and sentence-case vs. title-case variants of the same term went undetected. Also missed: spec tables where the term appeared as a row label rather than inline prose.

**Suggested fix:** When running the Step 2.8 cross-doc sync sweep for a removed term, generate a small synonym/casing set before grepping — at minimum: original, title-case, sentence-case, space-to-dash, and any alternate phrasing visible in adjacent docs. Run one grep per variant. Also explicitly check spec tables (files in `docs/specs/`), validator skill files, and plugin README/SKILL files as named sweep targets, since these are the most common homes for enumerated rule lists.
