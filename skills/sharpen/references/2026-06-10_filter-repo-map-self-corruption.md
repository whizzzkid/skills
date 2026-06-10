---
class: principle
date: 2026-06-10
skill: wk-sharpen
---

- **Rule:** When a replacement map — or its before→after examples in help
  text — is itself a committed artifact a later map run can re-process, write
  the "before" tokens as non-matching placeholders (`<n>`, `{slug}`).
- **Why:** A literal example token gets rewritten on the next map run, turning
  `before → after` into `after → after`. (Longest-first ordering is a separate,
  already-encoded rule; this is the self-corruption half.)
- **Where:** Step 5 mechanical overfit scan, Replacement-order rule,
  "Self-corruption guard" bullet.
