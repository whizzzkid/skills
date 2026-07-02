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
- **Escalation (2026-07-02):** re-violated — the prose bullet was skipped again
  under post-creation momentum. Bumped one notch (prose → `**Important:**`) and
  reworded to bind `gh pr view --web` atomically to the same response that runs
  `gh pr create`, before description sync / self-review / CI poll — not a
  skippable later bullet.
