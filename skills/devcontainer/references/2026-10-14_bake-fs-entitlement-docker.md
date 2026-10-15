---
class: principle
---

# Lowercase the devcontainer Compose project name

**Rule**

- Build the pinned teardown project name as the lowercased `<workspace-basename>_devcontainer`.

**Why**

- `docker compose -p "$(basename "$PWD")_devcontainer" down` failed on a mixed-case worktree directory. Verified
  locally: Compose 5.6 rejects `-p MyRepo_devcontainer` with `invalid project name ... must consist only of lowercase
  alphanumeric characters, hyphens, and underscores`. The bake-entitlement half of this learning lives in
  `2026-10-14_bake-fs-entitlement.md`; owned by `wk-devcontainer`, not `wk-docker`, because both incidents are
  devcontainer CLI behavior.

**Where**

`skills/devcontainer/SKILL.md` → Teardown / rebuild the stack (HARD RULE: pin the Compose project name).
