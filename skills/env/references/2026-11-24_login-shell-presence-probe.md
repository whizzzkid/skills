---
class: principle
date: 2026-11-24
skill: wk-env
---

# Login-shell presence probe before declaring a var unset

- **Rule:** When a user says a var is set but a plain check disagrees, probe the login shell before reporting missing
  or asking where it lives: `"$SHELL" -lic '[[ -n ${VAR:-} ]]' >/dev/null 2>&1 && echo set`. Probe by exit status
  only, never print the value. Found → run each consuming command through the same `"$SHELL" -lic '…'` wrapper.
- **Why:** A plain presence check in the agent's shell read not-set and the agent asked the user; the login-shell probe
  found it immediately (profile chain sourced only by login/interactive shells). Re-violation of the 2026-08-11
  interactive-shell fallback → escalated baseline → `**Important:**`. The prior probe also printed the value
  (`printenv`, contradicting the secret-echo rule), hardcoded `zsh`, and told the agent to export into a shell whose
  state does not persist across tool calls; all three corrected. Verified: clean-env plain check `unset`, login probe
  `set`, absent-var canary `missing`; login shells emit profile noise on stdout, so stdout is discarded and exit status
  decides.
- **Where:** `SKILL.md` → Step 3 → login-shell probe bullets; report outcome renamed "Resolved after login-shell probe".
