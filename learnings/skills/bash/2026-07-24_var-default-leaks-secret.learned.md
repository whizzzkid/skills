---
skill: wk-bash
date: 2026-07-24
type: correction
severity: high
verified-against-source: yes
---

Never use a parameter-default expansion to test whether a secret env var is set —
`${VAR:-...}` prints the secret's value when it IS set.

**What happened:** To check a private-registry credential was present, the agent ran
`echo "KEY set: ${KEY:+yes}${KEY:-NO}"`, expecting `yes` or `NO`. `${KEY:+yes}`
printed `yes`, and `${KEY:-NO}` then substituted the **actual key value** (the
default only applies when unset), so the live credential was written verbatim into
the session transcript. The key had to be treated as disclosed and rotated, which
then broke every dependency install for the rest of the session.

**Root cause:** `${VAR:-default}` is a value expansion, not a boolean. Pairing it
with `${VAR:+flag}` reads like a two-branch ternary but is two independent
expansions, and exactly one of them emits the secret on the set path — the common
path. The mistake is invisible when reading the line, because the intent
("presence check") and the mechanism ("expand the value") never appear together.

**Suggested fix:** Test presence with a test builtin that never expands into
output: `[ -n "$VAR" ] && echo set || echo unset`. When a fingerprint is genuinely
needed, emit only derived, non-reversible facts — `${#VAR}` for length and a hash
prefix (`printf %s "$VAR" | shasum | cut -c1-8`). Treat any `${SECRET:-` or
`${SECRET-` on a line that reaches stdout/stderr as a leak, and never put a secret
on a subcommand argv where `ps` can read it.
