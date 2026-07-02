---
skill: wk-adversarial-review
date: 2026-07-02
type: pattern
severity: high
---

A credential passed as a subcommand argument is exposed in process listings.

**What happened:** A fix wrote an auth token via `<tool> config set <key> <token>`. The token was visible to any local process via `ps`/`/proc` for the duration of the call — flagged as a secrets-handling blocker.

**Root cause:** Command-line arguments are world-readable in the process table; passing a secret as argv leaks it even when the destination file is 0600.

**Suggested fix:** When a review touches credential writes, grep the diff for secrets on argv (`config set`, `login --password`, `-H "Authorization: ..."`, `--token <x>`). Prefer writing the target file directly (atomic mktemp+mv with the value passed in-process), stdin, or an env var over passing the secret as a subcommand argument.
