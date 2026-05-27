---
class: principle
date: 2026-04-29
severity: low
---

- **Rule:** Compare `git log -1 --format='%ae' <branch>` against `git config user.email`; skip the `wk-retro` invocation when authors differ.
- **Why:** Retro reflects the current session; running it against another contributor's branch yields empty lenses and wastes the turn.
- **Where:** Step 4 — "Author check" bullet before the wk-retro invocation gate.
