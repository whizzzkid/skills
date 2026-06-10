---
class: principle
date: 2026-06-10
skill: wk-sitrep
severity: high
---

- **Rule:** Write dismissed-registry JSON with `jq -n` after stripping markdown
  escapes from string values; never raw bash interpolation. Validate the file
  parses after every write and roll back the last line on failure.
- **Why:** Interpolating a title that carries a non-JSON escape (SilverBullet's
  `\#` link-text escape) yields invalid JSON; every subsequent `jq` read fails
  and the filter silently stops applying.
- **Where:** Dismissed registry section (write pattern) + `end` Stage 5 write
  step. The registry feature was built in this run so the rule has a home.
