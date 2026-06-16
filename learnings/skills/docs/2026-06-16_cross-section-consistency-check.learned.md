---
skill: wk-docs
date: 2026-06-16
type: gap
severity: medium
---

Whole-doc consistency check when editing specs with cross-referencing sections.

**What happened:** A spec was updated in two separate sections covering the same concept (a startup assertion). One section was updated to reflect the new model default; the other section retained the original wording and qualifier. A bot review caught the contradiction.

**Root cause:** The edit targeted the primary narrative section; the risk-table row covering the same assertion was not checked for consistency. Diff-focused review misses cross-section drift.

**Suggested fix:** After any edit to a spec doc, grep the whole document for the core concept terms (e.g. "assertion", "startup", the affected component name) and review every hit for consistent tense, qualifier, and implementation status before committing.
