---
class: principle
skill: wk-adversarial-review
date: 2026-06-01
severity: high
---

- **Rule:** Flag as blocker any option-parsing command (`tar`, `rm`,
  `cp`, `grep`, `chmod`, `git`, `curl`, ...) fed array/glob-expanded
  untrusted names with no `--` option terminator before the positional
  args.
- **Why:** A basename like `-I.jsonl` or `--use-compress-program=evil`
  is parsed as an option, not a file — an RCE path a realpath/symlink
  guard misses, because it validates the path, not the basename's
  option-likeness.
- **Where:** Step 2 → new mechanical sweep 2.24 (argument-injection /
  missing `--` separator).
