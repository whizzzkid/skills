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
