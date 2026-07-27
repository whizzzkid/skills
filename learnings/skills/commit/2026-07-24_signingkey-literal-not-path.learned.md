---
skill: wk-commit
date: 2026-07-24
type: surprise
severity: medium
verified-against-source: yes
---

`user.signingkey` often holds a key *literal*, so probing with `ssh-keygen -Y sign -f "$(git config --get user.signingkey)"` misreports a signer outage as a missing key file.

**What happened:** Probing whether SSH commit signing was usable, the natural one-liner
`printf x | ssh-keygen -Y sign -n git -f "$(git config --get user.signingkey)"` returned:

```
Couldn't load public key ssh-ed25519 AAAA...: No such file or directory
```

That reads as "the configured key file is gone" and invites a hunt for a missing path. It
is an artifact of the probe: with `gpg.format=ssh`, `user.signingkey` commonly stores the
public key *material* inline rather than a path, and `-f` wants a path. Writing the value
to a temp file and re-probing surfaced the real fault — `communication with agent failed` —
the same error a real `git commit -S` then reproduced.

**Root cause:** `-f` takes a filename; git accepts either a filename or a literal key in
`user.signingkey` and writes the literal to its own temp file internally. Feeding the
literal straight to `-f` conflates two unrelated failures — "no such key file" (probe bug)
and "signer cannot sign" (the actual condition) — and the misleading one wins, because
`ssh-keygen` never reaches the agent.

**Suggested fix:** When probing signing capability, never pass `user.signingkey` to `-f`
unconditionally. Either

1. materialize it first — `git config --get user.signingkey > "$tmp"`, then
   `-f "$tmp"`; or
2. skip the `ssh-keygen` probe and use the authoritative test — an actual signed commit in
   a throwaway repo:
   `git -C "$tmp" -c gpg.format=ssh -c user.signingkey="$KEY" commit --allow-empty -S -m probe`.

Treat a `No such file or directory` from an `-f` probe as *probe-shaped*, not evidence
about the key or the agent, until the value is confirmed to be a path. Only a completed
signed commit proves signing works.
