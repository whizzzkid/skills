---
class: principle
skill: wk-commit
date: 2026-06-01
severity: high
---

- **Rule:** On a signing failure, diagnose environment inheritance
  (`GIT_CONFIG_PARAMETERS`, `ssh-add -l`) before touching git config;
  never write `git config --global user.signingkey` / `gpg.*` to "fix"
  it without explicit user instruction.
- **Why:** Signing config delivered via `GIT_CONFIG_PARAMETERS` is not
  inherited by subprocesses; forcing a global-config write shadows the
  user's env-based config and persists as destructive global state.
- **Where:** Commit Signing → "On signing failure" steps 2–3 + new HARD
  RULE forbidding git-config writes.
