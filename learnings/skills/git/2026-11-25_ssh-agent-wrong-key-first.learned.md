---
skill: wk-git
date: 2026-11-25
type: correction
severity: medium
verified-against-source: yes
---

When an SSH push fails with `signing failed ... communication with agent failed`, the agent can be offering the wrong key. Pin the right one through `GIT_SSH_COMMAND`. Don't fall back to HTTPS.

**What happened:** A multi-key password-manager agent offered a key from another machine first, and the agent could not sign with it. The agent was misread as locked, and HTTPS fallbacks were tried instead. A global `url.git@github.com:.insteadOf https://github.com/` rewrote the HTTPS URL back to SSH. The user pointed out that the wrong key was being loaded.

**Root cause:** `ssh-add -l` was never checked. The agent held several GitHub keys, and the failing one was tried first.

**Suggested fix:** On an agent signing failure, run `ssh-add -l`, pick the key for this machine, and export its public half (`ssh-add -L | grep '<label>' > <tmp.pub>`). Then push with `GIT_SSH_COMMAND='ssh -o IdentitiesOnly=yes -i <tmp.pub>' git push ...`; the agent signs with the matching private key. Never edit `$HOME/.ssh/config` or the git config to do this.
