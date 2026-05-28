---
class: principle
date: 2026-05-28
source:
  - ~/.claude/memory/feedback_probe_not_parse_error_text.md
severity: medium
---

- **Rule** — detect tool capability by invocation + exit code against a known-good input; never branch on `grep`-ing the stderr wording.
- **Why** — error strings differ between GNU coreutils, BSD/macOS, BusyBox, and library wrappers; a wording-based fallback fails closed on the variant it was supposed to handle (e.g., local macOS passes, Alpine CI fails on different error text).
- **Where** — Shell (bash/sh) section in `wk-workstyle` SKILL.md, after the existing bash hard-rules bullets.
