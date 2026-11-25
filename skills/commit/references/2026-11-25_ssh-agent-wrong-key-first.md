---
class: principle
skill: wk-commit
date: 2026-11-25
---

# SSH-agent push refusal: list the agent's keys and pin this machine's before asking

- **Rule:** On a push refused with `sign_and_send_pubkey: signing failed ... communication with agent failed`, run
  `ssh-add -l` before calling the agent locked. Several keys for the host → write this machine's public half to a temp
  file and make the one retry `GIT_SSH_COMMAND="ssh -o IdentitiesOnly=yes -i <tmp.pub>" git push`. Still refused, or
  only one key → stop and ask the user to unlock or restart the agent. Never edit `$HOME/.ssh/config` or git config to pin.
- **Why:** A multi-key password-manager agent offered a key from another machine first and could not sign with it. The
  failure read as a locked agent, so HTTPS fallbacks were chained (and defeated by an `insteadOf` rewrite) until the
  user pointed at the wrong key. The earlier "retry once, then ask" fold rested on an unverified locked-agent root
  cause; a blind retry re-offers the same key in the same order and fails identically.
- **Verified:** `ssh_config(5)` `IdentityFile`: a public key file selects the matching private key loaded in
  `ssh-agent` when the private file is absent. `ssh -G -o IdentitiesOnly=yes -i <pub-only file> <host>` resolves to
  `identitiesonly yes` with that file as the sole `identityfile`.
- **Where:** `SKILL.md` → Pushing → Hook and verify rules → SSH-agent refusal bullet. Refines
  [`2026-11-25_ssh-agent-push-fallback.md`](2026-11-25_ssh-agent-push-fallback.md).
