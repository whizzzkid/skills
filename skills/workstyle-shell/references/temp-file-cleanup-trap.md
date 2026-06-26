---
class: principle
---

**Rule:** Register a cleanup trap the moment you create a temp file or dir —
`trap 'rm -rf "$tmp"' EXIT INT TERM`, in the same commit. Never defer it to a
follow-up fix, and never cover `EXIT` alone.

**Why:** An `EXIT`-only trap leaks the tempfile on Ctrl-C (`INT`) and on CI
cancellation (`TERM`). Deferring the guard to a later bot finding means the leak
ships first.

**Where:** wk-workstyle-shell Rules — paired with the `local`-scope trap rule.
