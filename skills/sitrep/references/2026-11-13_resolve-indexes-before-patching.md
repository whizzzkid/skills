---
class: principle
---

# Resolve every target index before patching a page in place

- **Rule** — When transforming the prior page, build an `{old data-t: line index}` map before any edit, set dropped
  lines to a sentinel, apply inserts from the highest index down, filter sentinels, then renumber. Run any clipboard
  readback under a timeout and report the copy payload as unverified on timeout.
- **Why** — A replaced span loses the `data-t` used to find it, so a later lookup by the old ID misses; collecting raw
  indexes and inserting first shifts every later drop index. A clipboard read can hang indefinitely on a missing
  read permission.
- **Where** — Stage 4 "transform the prior page" sub-bullet; `standup-copy-block.md` verification step 3.
