---
class: principle
---

# Probe the login shell for env-delivered signing config

**Rule** — On a signing failure where config files lack the key, test the login shell (`"$SHELL" -lic`) for
`GIT_CONFIG_PARAMETERS` / `GIT_CONFIG_COUNT` presence before touching or proposing any config change. Set there → run
the commit/push through the login shell. Never print the variable's value; never ask the user to edit git config.

**Why** — Env-injected git config is exported only by the login profile; a non-login agent shell (e.g. a resumed
session) never inherits it, so an empty direct-shell check and a key-less global config are both false negatives.
Asking the user to edit config shadows the env-based setup exactly as writing it would.

**Where** — `SKILL.md` → Commit Signing (escalated baseline → `**Important:**`: re-violation of the shipped
"diagnose env inheritance before touching config" rule) + `commit-signing.md` step 2 (value-printing `echo` replaced
with a two-shell presence probe).
