---
skill: wk-workflow
date: 2026-07-24
type: gap
severity: medium
---

A secret rotated in the user's interactive shell can never reach the agent's
subprocess — after one failed source, ask for a session restart instead of
iterating on shell files.

**What happened:** A dependency install failed with 401 on a private package
registry. The agent spent several turns hunting for the file that exports the
credential (`$HOME/.profile`, `$HOME/.zshrc`, …), sourcing it, and re-fingerprinting the
value — each attempt returning the same stale key, because the credential is
injected by a secrets manager into the interactive shell only. The loop ended
only when the user restarted the session.

**Root cause:** No rule distinguishing "the env var is misconfigured" (fixable
in-process) from "the env var is stale in this process" (not fixable in-process).
Sourcing a profile from a tool subprocess cannot import a value a secrets manager
minted after the process started, so every retry is guaranteed to fail
identically.

**Suggested fix:** Add an env-staleness check to the credential-failure path:
fingerprint the value (hash prefix + length) once, source the candidate profile
once, re-fingerprint. Unchanged fingerprint → declare the value stale-in-process
and ask the user to restart the session (or run the command in their own shell).
Never source a third file or retry a fourth time.
