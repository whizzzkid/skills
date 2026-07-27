---
class: principle
date: 2026-06-10
severity: high
---

- **Rule:** Target bash 3.2 for any hook/script that may run under the macOS
  system bash; avoid bash-4+ builtins (`mapfile`/`readarray`, `declare -A`,
  `${var^^}`/`${var,,}`, negative array indices). Verify with `/bin/bash`.
- **Why:** macOS ships bash 3.2 as `/bin/bash`; `mapfile -t arr < <(...)` fails
  with `mapfile: command not found` on the first commit a lefthook hook runs.
- **Where:** Rules section — "Target bash 3.2" bullet.

## Capability-probe example

Relocated from `SKILL.md` (same bullet) to hold the body under the size ceiling.
The rule itself stays inline: detect support for a flag or feature by running it
against a known-good input and branching on the exit code — never by grepping the
stderr wording, which differs across GNU coreutils, BSD/macOS, BusyBox, and
library wrappers.

```bash
# WRONG — wording varies by vendor (BusyBox vs GNU vs macOS)
if tool -flag -- "$arg" 2>&1 | grep -q "invalid option"; then
    fallback
fi

# CORRECT — capability probe
if tool -flag -- /known-good >/dev/null 2>&1; then
    use_tool
else
    fallback
fi
```
