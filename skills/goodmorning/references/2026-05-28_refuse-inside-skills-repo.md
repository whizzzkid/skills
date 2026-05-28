---
class: principle
date: 2026-05-28
source:
  - ~/.claude/memory/project_sitrep_skip.md
  - ~/.claude/memory/feedback_use_zed_editor.md
severity: low
---

- **Rule** — abort `wk-goodmorning` / `wk-goodevening` when `$PWD` is `$WK_SKILLS_HOME` or a subdirectory of it; sitrep output belongs in the project the brief describes.
- **Why** — a misplaced run leaves a stray `sitrep/<YYYY>/...` tree in the skills repo, which then ships in commits and pollutes the working directory.
- **Where** — new HARD RULE block before "Determine dates and paths" in both `wk-goodmorning` and `wk-goodevening` SKILL.md.
- **Companion (one-off)** — open files for user review via `zed <path>`, not `open` or `vim` (per user preference); kept as memory only, no SKILL.md edit since it spans many skills as a soft default.
