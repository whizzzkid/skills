---
class: principle
---

# Post-patch assertions match the attribute form, not substrings canonical markup emits

- **Rule** — Assert uniqueness on the `data-t="t` attribute form (quote + `t` prefix), and exempt the standup
  copy-block line from the stray-literal-`\n` grep.
- **Why** — The canonical toggle handler contains the string `'data-t='` and the copy block contains `join('\n')`;
  whole-line counts of those substrings fail every valid page, so the check, not the markup, is the defect.
- **Where** — `SKILL.md` Stage 4 "Multi-line patch" sub-bullet.
