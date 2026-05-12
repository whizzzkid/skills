---
date: 2026-05-12
slug: mise-profiles-for-container-tools
---

- **Rule:** Put container-only tools in `mise.devcontainer.toml` and set `MISE_PROFILE: devcontainer` in compose; keep host `mise.toml` lean.
- **Why:** Host developers should not install container-only tools (e.g., `gh` pinned to a CI version); profile-merge keeps both audiences served from one repo.
- **Where:** Step 2.5 "Optional — mise profiles for container-only tools".
