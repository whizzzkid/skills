---
skill: wk-git
date: 2026-07-22
type: correction
severity: medium
---

SSH signing key mismatch diagnosis

**What happened:** `git commit` failed with "Couldn't find key in agent?" when gpg.format=ssh and a configured signing key was in use. The agent asked the user for approval to change the git config, rather than diagnosing the mismatch first.

**Root cause:** When signing fails, the agent should compare the configured key (via `git config user.signingkey`) against the keys loaded in the SSH agent (`ssh-add -L`) before proposing config changes. The failure was caused by a key mismatch: the SSH auth socket auto-provisioned a new Ed25519 key mid-session (rotating the hardware-backed key), while git still referenced the old one. Without comparing, the agent missed the diagnosis.

**Suggested fix:** Before asking for config changes on SSH signing failures, run: (1) extract configured key via `git config user.signingkey`, (2) list loaded keys via `ssh-add -L`, (3) compare; if mismatch, inform the user that the configured key is not loaded and suggest reloading. Only suggest config changes if the key is absent from the agent entirely.

