---
class: principle
date: 2026-08-10
skill: wk-workstyle-shell
---

# echo interprets escapes, corrupting JSON

- **Rule:** Use `printf '%s'` or a direct pipe when passing captured JSON to a
  parser. `echo` interprets `\r`, `\n`, `\t` as control characters, producing
  `jq` parse errors (`Invalid string: control characters`).
- **Why:** Shell captured JSON containing escaped carriage returns; `echo`
  interpreted those escapes and `jq` rejected the result.
- **Where:** Rules section — new printf-over-echo bullet.
