---
skill: wk-commit
date: 2026-06-01
type: surprise
severity: medium
---

`git log --show-signature` reports "No signature" when `gpg.ssh.allowedSignersFile` is missing from the subprocess env — this is a local-verification failure, not an unsigned commit.

**What happened:** After committing with `git -c user.signingkey=<key>`, `git log --show-signature` printed "No signature" and `%G?` returned `N`. The commit was actually signed; `git cat-file commit HEAD` showed a valid `gpgsig -----BEGIN SSH SIGNATURE-----` block.

**Root cause:** `gpg.ssh.allowedSignersFile` is delivered via `GIT_CONFIG_PARAMETERS` in the user's interactive shell but not inherited by agent subprocesses. Without it, git cannot resolve the public key to verify against, so it reports no signature even when the `gpgsig` header is present. GitHub verifies against the account's registered SSH keys server-side, so the push still lands as verified.

**Suggested fix:** When `git log --show-signature` shows "No signature" on a commit that used `git -c user.signingkey=...`:
1. First check `git cat-file commit HEAD | head -20` for the `gpgsig` header — if present, the commit IS signed.
2. To verify locally: `git -c gpg.ssh.allowedSignersFile=<(ssh-add -L | awk -v e="$(git log -1 --format='%ce')" '{print e, $1, $2}') log -1 --show-signature`.
3. Never re-commit or delay a push because of this false alarm.
