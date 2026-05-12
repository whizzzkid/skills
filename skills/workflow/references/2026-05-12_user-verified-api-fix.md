---
name: user-verified-api-fix
description: Pause before commit when only the user can reproduce the failing external call.
---

- **Rule:** When the agent cannot rerun the failing external call locally,
  pause before `wk-commit`, hand the user the exact command and success
  criterion, and commit after they confirm success.
- **Why:** API-shape fixes committed without a live retry land a follow-up
  PR if the diagnosis was wrong; the user often holds the token/env the
  agent does not.
- **Where:** "External-call reproduction before fix and commit" HARD RULE in
  `workflow/SKILL.md`.
