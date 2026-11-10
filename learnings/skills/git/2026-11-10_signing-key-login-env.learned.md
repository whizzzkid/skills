---
skill: wk-git
date: 2026-11-10
type: correction
severity: medium
verified-against-source: yes
---

Commit signing failed because the agent shell lacked a login-profile-exported GIT_CONFIG_PARAMETERS.

**What happened:** `git commit` failed with "either user.signingkey or gpg.ssh.defaultKeyCommand needs to be
configured". The agent inspected the global gitconfig, found no key, and asked the user to edit global config —
twice — before the user pointed out the key lives in `GIT_CONFIG_PARAMETERS`.

**Root cause:** The signing key is injected by an env file sourced only by the user's login shell; the agent's
non-login shell (resumed session) never inherited it. Verified: `zsh -lic` showed the variable set.

**Suggested fix:** On any git config/signing error where config files lack the key, probe the login shell
(`zsh -lic 'test -n "${GIT_CONFIG_PARAMETERS:-}"'`, also `GIT_CONFIG_COUNT`) before asking the user; if set there,
run git commit/push via `zsh -lic '...'`. Never print the variable's value.
