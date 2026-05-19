---
class: principle
date: 2026-05-19
---

- **Rule:** When bot reviewers exist in the pre-push map, note in the
  verdict that post-push thread count may shrink and that callers must
  re-fetch threads by stable identity tuple.
- **Why:** Bots that recreate their review object on each push retract
  pre-push threads and may post a single replacement before their
  database catches up — caller misreads collapse as regression.
- **Where:** Step 5 Verdict — "Note bot reviewers in the verdict".
