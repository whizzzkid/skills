---
class: principle
skill: wk-testing-skeleton
date: 2026-11-20
---

# Fix the earliest failing test first; later failures may be cascades

- **Rule:** When a suite shows a failure that passes when run in isolation, fix the earliest failing test first and
  treat later failures as possible cascades. Resolve DOM or global handles at schedule time, except where
  re-resolution is the behavior under test.
- **Why:** A test that throws before awaiting its timers leaves callbacks pending. They re-resolve globals such as
  `document` when they fire, so they write into the next test's fixture and fail an unrelated test. Teardown swaps
  the globals but cannot cancel module-level timers.
- **Where:** `SKILL.md` → Stage 3 (Write the tests). Source: testing-skeleton learning and the session-7 retrospect.
