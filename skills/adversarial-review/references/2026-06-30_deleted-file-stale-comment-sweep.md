---
class: principle
---

- **Rule:** For every file deleted in the diff, grep the entire repo (comments,
  docstrings, string literals — not just code/symbol references) for the deleted
  file's basename. Each surviving mention in a non-historical file is stale-
  reference drift to fix in the same PR. (Sweep 2.61.)
- **Why:** The symbol-keyed stale-term sweep (2.8) misses a deleted *file* whose
  name lives only in prose — a neighboring build/codegen "keep {file} in sync"
  comment compiles cleanly after the deletion, so an automated reviewer catches it
  post-push instead of the sweep catching it pre-push.
- **Where:** Step 2 sweep catalog (extended), row 2.61.
