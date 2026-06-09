---
class: principle
skill: wk-pr
date: 2026-06-09
severity: medium
---

- **Rule:** Run `gh pr view --web` as soon as `gh pr create` succeeds; skip
  only in a headless / non-interactive session.
- **Why:** Reporting the URL in text alone makes the user click manually — the
  freshly created PR should open automatically.
- **Where:** Step 3 (Post-Creation Workflow), leading "Open it in the browser
  first" bullet.
