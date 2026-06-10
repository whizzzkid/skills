---
class: principle
date: 2026-06-10
skill: wk-sitrep
---

- **Rule:** Validate the dismissed registry parses immediately after each
  append; remove the last line if the write broke the file.
- **Why:** Without a write-time guard, an invalid entry surfaces only later
  when the filter reads keys — after the filter has silently been a no-op.
- **Where:** Dismissed registry write block (validate + `sed` rollback).
