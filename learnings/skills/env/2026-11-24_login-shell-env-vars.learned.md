---
skill: wk-env
date: 2026-11-24
type: correction
severity: medium
verified-against-source: yes
---

A variable "provided in the environment" may exist only in the login profile; probe with a login shell before
concluding it is unset.

**What happened:** An env-var presence check in the agent's shell returned not-set, and the agent asked the user where
the key lived. The user replied that it was in the shell. A `zsh -lic` probe found it immediately, because profile
files sourced only by login/interactive shells export it.

**Root cause:** The agent's shell does not source the user's login profile chain.

**Suggested fix:** When a user says a variable is set but a plain check disagrees, re-probe for presence only via
`"$SHELL" -lic '[[ -n ${VAR:-} ]] && echo set'`, never printing the value, and run any command that needs it through
the same login-shell wrapper.
