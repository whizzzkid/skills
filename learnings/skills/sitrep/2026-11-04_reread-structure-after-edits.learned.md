---
skill: wk-sitrep
date: 2026-11-04
type: correction
severity: medium
verified-against-source: n/a
---

After applying many targeted edits to a long document, re-read it whole for structure, not just lint.

**What happened:** Reviewer proposals were applied as quote-for-quote replacements and inserts. Content moved into
sections where it no longer fit (non-AI stats under an AI heading, guardrails under product), and heading styles were
mixed. Asked "is the markdown formatted correctly?", the agent ran a linter and width checks only and reported clean.
The user had to point out the misplacements.

**Root cause:** Validation covered syntax only; nothing checked that each item still matched its heading after edits
that moved or added content.

**Suggested fix:** After any batch of edits that adds or moves content, do one full top-to-bottom read: each item sits
under the right heading, heading style is consistent, no duplicated points, pronoun and voice consistent. Treat
"formatted correctly" questions as structure + syntax, not syntax alone.
