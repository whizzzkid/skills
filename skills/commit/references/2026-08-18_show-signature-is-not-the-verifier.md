---
class: principle
source: contradiction found during a sharpen audit; reproduced in-session
date: 2026-08-18
severity: medium
---

## The signature verifier and the signature itself are different questions

The rewrite section prescribed `git log --show-signature <base>..HEAD` as proof that a
rewrite re-signed its commits. The subsection immediately below it declared that same
output unreliable and made the raw object authoritative. Both statements were installed
and they contradicted each other.

**Reproduced:** on a commit signed by this configuration, `git log -1 --format='%G?'`
printed `N` alongside `error: gpg.ssh.allowedSignersFile needs to be configured and
exist for ssh signature verification`, while `git cat-file commit <sha>` showed a
`gpgsig` header. The commit was signed. The verifier simply had no public key to check
it against, which is the normal local state here because that config arrives through an
env-delivered mechanism a subprocess does not inherit.

**Why this was worse than a gap:** the wrong prescription does not fail open, it fails
*loud and backwards*. It reports a correctly signed commit as unsigned, and the rule it
serves — never let a rewrite emit unsigned commits — then drives the agent to re-sign or
re-commit work that was already correct. A rule that manufactures a false positive on
the healthy path is more damaging than no rule.

**Resolution:** the requirement stays; only the instrument changes. Verification reads
raw `gpgsig` per commit across the rewritten range, which is what the false-alarm
subsection already established for a single commit. The range form supersedes it, so
that subsection now defers to the command above rather than repeating a narrower one.

**General shape:** when a check and its subject can fail independently, name which one a
red result indicts. Here an unconfigured verifier and an unsigned commit produce the same
output, so the output cannot distinguish them and the raw artifact has to be consulted
instead.

**Landed in:** `SKILL.md` "Preserve signatures when rewriting history".
