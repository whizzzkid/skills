---
skill: wk-commit
date: 2026-06-01
class: principle
type: surprise
severity: medium
---

# SSH-signed commits: "No signature" is often a local-verification false alarm

- **Rule:** When `git log --show-signature` reports "No signature" (or
  `%G?` returns `N`) for an SSH-signed commit, do not treat it as
  unsigned. Confirm by inspecting the raw object —
  `git cat-file commit HEAD` shows `gpgsig -----BEGIN SSH SIGNATURE-----`
  when signed. Never re-commit, re-sign, or delay a push on a "No
  signature" report alone. To verify locally, build a temp allowed-signers
  from the loaded key:
  `git -c gpg.ssh.allowedSignersFile=<(ssh-add -L | awk -v e="$(git log -1 --format='%ce')" '{print e, $1, $2}') log -1 --show-signature`.
- **Why:** Verification needs `gpg.ssh.allowedSignersFile` to resolve a
  public key. That config is delivered via `GIT_CONFIG_PARAMETERS` in the
  interactive shell and is not inherited by agent subprocesses, so git
  reports "No signature" even though the commit carries a valid signature.
  The hosting service verifies against the account's registered keys
  server-side, so the commit lands verified after push.
- **Where:** `Commit Signing → Preserve signatures when rewriting history`
  → subsection "'No signature' can be a local-verification false alarm".
