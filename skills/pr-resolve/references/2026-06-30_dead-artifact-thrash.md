---
class: principle
skill: wk-pr-resolve
date: 2026-06-30
---

**Rule:** When bot re-fires concentrate on prose in a single non-code file, grep
the repo for any code/CI/prompt that reads the file's *content* (not merely
references its path or bundles it) before another wording pass. If nothing
consumes it, offer delete/restructure first.

**Why:** The thrash gate treats every re-fire as "fix the prose better." A file
no consumer reads cannot have its findings fixed into convergence — only
restructuring or deletion ends the loop structurally. Each reword just triggers
the next finding.

**Where:** Step 4 bot / non-convergence handling, alongside the
`(path_prefix, concern_class)` thrash tracking.
