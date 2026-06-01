---
skill: wk-commit
date: 2026-06-01
type: correction
severity: high
---

Never write to git config to fix signing failures — diagnose why the environment isn't loaded instead.

**What happened:** `git commit` failed with "user.signingkey not set" even though the 1Password SSH agent was running and had a key loaded. Rather than diagnosing the root cause, the agent ran `git config --global user.signingkey <key>` to force a fix. The signing key was actually delivered via `GIT_CONFIG_PARAMETERS` env var set in the user's interactive shell — the agent's subprocess simply didn't inherit it, and overwriting global config shadowed the proper env-based config.

**Root cause:** Treating a signing failure as a configuration gap to fill, rather than an environment inheritance failure to diagnose. `GIT_CONFIG_PARAMETERS` is a git-native mechanism for injecting config at process boundary — overriding it with `git config --global` creates permanent global state that may conflict with the user's intended config management.

**Suggested fix:** On any signing failure, follow this diagnostic sequence before touching any git config:
1. `echo "$GIT_CONFIG_PARAMETERS"` — check if signing config is present but not inherited.
2. `ssh-add -l` — confirm the agent has the key.
3. If env is missing but key is loaded, the fix is to run the commit via the user's shell (which has the env) or to ask the user to run it directly — not to write global config.
4. `git config --global` writes are permanently destructive to env-based config management. Never use them to "fix" a signing failure.

**How to apply:** When signing fails, stop at step 2 of wk-commit's signing-failure protocol and run the diagnostic above before declaring the environment broken. Never write `git config --global user.signingkey` or `git config --global gpg.*` without explicit user instruction.
