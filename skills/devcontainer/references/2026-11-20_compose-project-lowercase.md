---
class: one-off
skill: wk-devcontainer
date: 2026-11-20
---

# Stale un-lowercased teardown command in a reference

- **Scenario:** A shutdown ran `docker compose -p "$(basename "$PWD")_devcontainer" down` in a worktree whose basename
  had uppercase letters.
- **Symptom:** Compose failed with "invalid project name"; the devcontainer CLI had created the project lowercased.
- **Fix:** `SKILL.md` already lowercases the basename in every teardown command. The `teardown-project-name.md`
  reference still showed the un-lowercased form, so it now matches `SKILL.md`.
- **Why not promoted:** The rule is already in `SKILL.md`; only a stale copy in a reference drifted.
