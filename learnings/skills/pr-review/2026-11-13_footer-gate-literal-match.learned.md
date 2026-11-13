---
skill: wk-pr-review
date: 2026-11-13
type: correction
severity: low
verified-against-source: n/a
---

Footer pre-emit gate grep must use the literal footer string, not a hand-typed fragment.

**What happened:** A footer count grep used a remembered URL fragment that differed from the canonical footer, returned 0, and nearly read as "footer missing" on a correct payload.

**Root cause:** Gate pattern was typed from memory instead of copied from the canonical footer block.

**Suggested fix:** Build the gate pattern from the same variable used to render the footer (render once, grep -F that exact string); expect count = 1 + number of inline comments.
