---
class: principle
---

# Diagnose an SSH signing-key mismatch before proposing anything

**Rule** — On an SSH-format signing failure (`gpg.format=ssh`, error `Couldn't
find key in agent?`), compare the configured key against the loaded set —
`git config user.signingkey` vs `ssh-add -L` — before proposing any change. A
configured key present but absent from `ssh-add -L` means it is not loaded, not
misconfigured; ask the user to re-add that exact key. Only an entirely empty
agent means no signing key at all. Never a git-config change (existing HARD RULE).

**Why** — A hardware-backed / auto-provisioning SSH agent can rotate or
re-provision the loaded key mid-session while git still references the old one.
`ssh-add -l` alone (does the agent hold *a* key) misses the mismatch; only
comparing the configured key against the loaded list surfaces it. Skipping the
comparison led to asking the user for a config change instead of the real fix
(reload the key).

**Where** — `wk-commit` Commit Signing → "On signing failure" step 2b.
