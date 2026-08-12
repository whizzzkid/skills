---
skill: wk-workflow
date: 2026-08-10
type: correction
severity: medium
verified-against-source: yes
---

Anchor top-level TOML settings before the first table header.

**What happened:** A context-free patch appended global settings after the final table header, silently nesting them
inside that table instead of applying them globally.

**Root cause:** TOML table scope continues until the next table header; an insertion without a stable top-level anchor
does not guarantee top-level placement.

**Suggested fix:** Before patching TOML, identify the first table header and insert global keys immediately before it;
then validate both parsing and the resolved configuration.
