---
class: principle
skill: wk-refactor
date: 2026-11-20
---

# Prove a formatting-only claim with parse trees

- **Rule:** For a "formatting-only, no behaviour change" claim, compare position-stripped parse trees of base and
  HEAD per file. Identical trees prove the claim. Run one file with a known structural change through the same
  compare as the negative control.
- **Why:** A reformat diff touches nearly every line, so reading it cannot show that behavior is unchanged. A
  parse-tree compare with locations stripped ignores layout and catches any real change. The negative control proves
  the compare can fail.
- **Where:** `SKILL.md` → Stage 3 (Source-of-truth compare). Source: session-6 retrospect, "What worked".
