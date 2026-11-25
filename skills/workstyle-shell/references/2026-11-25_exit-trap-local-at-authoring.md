---
class: principle
skill: wk-workstyle-shell
date: 2026-11-25
---

# EXIT trap vs `local`: check at authoring, and `set -u` flips the exit status

- **Rule:** When writing any `trap` body, declare every variable it names at script scope (init `""`) before the
  first function, register the trap once at script scope, and let one cleanup function own every resource.
- **Why:** A function created a tempfile in a `local` and re-registered the script-level EXIT trap. Under `set -u` the
  trap raised `unbound variable` after the success line printed, so output was correct but every happy-path test
  failed on exit status. The existing rule described only the silent-leak symptom and read as a review-time finding,
  so it did not fire while the trap was being written.
- **Verified:** `set -euo pipefail`; a function with `local tmp; tmp=$(mktemp); trap 'rm -f "$tmp"' EXIT` that prints a
  success line → the line prints, then `tmp: unbound variable`, rc=1 (bash 3.2).
- **Where:** `SKILL.md` → Rules → EXIT-trap `local` bullet (escalated to `**Important:**`, authoring check added).
  Escalation recorded in [`trap-local-var-invisible.md`](trap-local-var-invisible.md).
