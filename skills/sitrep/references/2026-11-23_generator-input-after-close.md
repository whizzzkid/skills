---
class: principle
skill: wk-sitrep
date: 2026-11-23
---

# After a rollover close, transform the pre-close page

- **Rule:** After a rollover close, save the pre-close prior page (or read it from the commit before the close) as the
  start transform's input, and keep the close commit separate. Every insertion anchor must match exactly one line:
  assert count == 1 before writing.
- **Why:** The close step added frontmatter and heading lines to the prior page and committed it. The start
  generator, built against the original line numbers, then hit a handler-drift assertion and had to be resent in full,
  since no script file is allowed. A later insertion anchored on a substring shared by two lines duplicated the
  inserted items; the post-insert count assertion caught it.
- **Where:** `SKILL.md` → Stage 4 transform rules (Mostly carry-over → transform the prior page).
