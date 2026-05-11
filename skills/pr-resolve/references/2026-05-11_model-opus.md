---
date: 2026-05-11
source: learnings/skills/pr-resolve/2026-05-11_use-opus-for-complex-skills.md
---

- **Rule:** Declare `model: opus` in frontmatter for skills whose core value is multi-step judgment (deep code reasoning, design-signal detection, multi-surface triage, fix generation, loop-back logic).
- **Why:** Defaulting to the session's active model risks running judgment-heavy skills on a smaller model and degrading output quality.
- **Where:** Frontmatter `model:` field — matches pattern already set by wk-pr-review, wk-self-review, wk-sharpen.
