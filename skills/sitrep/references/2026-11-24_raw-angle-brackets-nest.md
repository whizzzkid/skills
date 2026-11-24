---
class: principle
source: learnings/skills/sitrep/2026-11-24_raw-angle-brackets-nest.learned.md
date: 2026-11-24
severity: medium
---

## Strip raw angle brackets from generated item text

- **Rule:** The span generator replaces every `<` and `>` in item text (placeholders, generics, comparison operators)
  with braces or a dash, and asserts before writing that no span text holds `<` outside the canonical markup. The
  Stage 5 render gate stays the backstop.
- **Why:** An item quoting an angle-bracketed placeholder inside a column span was parsed as an HTML tag. The file on
  disk looked fine, but the rendered page collapsed to one column with the other two nested inside it. The generator
  escaped only `#`, and the existing ban covered entities and `<br>` lines, not arbitrary literal `<`.
- **Where:** `SKILL.md` Stage 4, "Generate spans; never hand-type them". Secondary note (remote-access probe before
  auto-review dispatch) landed in `auto-review.md`.
