---
class: principle
date: 2026-06-16
---

- **Rule:** Flag new/changed function doc comments whose single sentence
  chains independent reasons (`because` / `while` / `so that`); split each.
- **Why:** Phrasing one independent concern as a precondition of another
  misleads readers about the causal relationship.
- **Where:** Sweep 2.4 (comment accuracy pass) — "Conflated-concern check".
