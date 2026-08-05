---
skill: wk-self-perf
date: 2026-08-05
type: correction
severity: medium
verified-against-source: n/a
---

Preserve sections the user explicitly marks as final during later polish passes.

**What happened:** A prose-polish pass compressed a forward-looking section that the user wanted retained verbatim.

**Root cause:** The skill treats all narrative sections as equally editable after a broad polish request and does not
track section-level keep-as-is constraints across revisions.

**Suggested fix:** Record user-owned or approved sections as immutable edit boundaries and exclude them from later
rewrites unless the user explicitly reopens their content.
