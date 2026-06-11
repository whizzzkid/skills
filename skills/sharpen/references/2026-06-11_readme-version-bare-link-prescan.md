---
class: principle
---

- **Rule** — When first adding the `**Version:**` line to an existing skill
  README, pre-convert any bare `wk-*` mention to a relative link in the same
  edit.
- **Why** — Touching the README stages the whole file; `check-skill-links`
  then blocks on pre-existing bare links, forcing a re-commit (hit twice in
  one batch run).
- **Where** — Step 7 "Sync skill README" sub-section, README-version bullet.
