---
class: principle
---

**Rule:** Grep for `\n`/`click` is necessary but not sufficient — render every
added or modified mermaid diagram in a browser before committing.

**Why:** Grep catches only known string patterns. A structural syntax error
(malformed `opt`/`alt`/`loop`/`par` block, stray keyword, unclosed subgraph) is
invisible to both `git diff` and grep and surfaces only on render, breaking the
whole page.

**Where:** Step 5 (Validate the render) — HARD RULE.
