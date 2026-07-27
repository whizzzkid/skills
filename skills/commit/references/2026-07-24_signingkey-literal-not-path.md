---
skill: wk-commit
date: 2026-07-24
class: principle
type: surprise
severity: medium
---

# `user.signingkey` may hold a key literal — a file-taking probe flag misreports

- **Rule:** Never pass `user.signingkey` straight to a flag that wants a filename
  (`ssh-keygen -Y sign -f`). Materialize it first
  (`git config --get user.signingkey > "$tmp"`), or probe with a real signed
  commit. Treat an error naming the probe's own operand as *probe-shaped* — not
  evidence about the key or the agent — until the value is confirmed a path. Only
  a completed signed commit proves signing works.
- **Why:** Under `gpg.format=ssh`, git accepts either a path or the public key
  *material* inline in `user.signingkey`, writing a literal to its own temp file
  internally. `-f` accepts only a path, so feeding it a literal fails with
  `Couldn't load public key …: No such file or directory` before the agent is ever
  contacted. That conflates two unrelated conditions — a missing key file (probe
  bug) and a signer that cannot sign — and the misleading one wins, sending the
  diagnosis after a nonexistent path. Reproduced on the same host: the literal
  form returned the `No such file` error while the materialized form returned the
  real `communication with agent failed`, matching what a real `commit -S` then hit.
- **Where:** `Commit Signing` → `On signing failure` step `2c`.
- **Rejected:** relaxing the check to "just trust `ssh-add -l`" — a listed key does
  not prove signing capability, so it would swap one false signal for another.
