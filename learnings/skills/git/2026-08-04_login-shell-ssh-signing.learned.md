---
skill: wk-git
date: 2026-08-04
type: correction
severity: medium
verified-against-source: yes
---

Load the configured SSH agent before a signed merge

**What happened:** A signed merge reached commit creation in a non-interactive shell, then failed
because the shell had neither a signing key configured nor a connection to the hardware-backed SSH
agent.

**Root cause:** The repository required SSH-signed commits, while the current non-interactive shell
did not load the profile that exports the SSH agent socket. A login shell loaded the profile and
exposed the same public key embedded in the branch's prior signed commits.

**Suggested fix:** Before starting a signed merge, verify `git config user.signingkey` and
`ssh-add -L`. When the direct shell cannot reach the agent, run the merge commit through the
project's login-shell environment and pass the verified existing signing key with `git -c`; never
start the merge first or weaken signing.
