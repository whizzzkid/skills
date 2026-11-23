---
skill: wk-testing-skeleton
date: 2026-11-20
type: surprise
severity: medium
verified-against-source: yes
---

A test that throws before awaiting its timers leaks callbacks that resolve the global `document` of the NEXT test, producing a misleading second failure.

**What happened:** One assertion failed early; its pending setTimeout later wrote into the following test's region via the global `document`, so an unrelated test failed in the full run but passed in isolation.

**Root cause:** Deferred callbacks re-resolve globals at fire time; teardown swaps globals but cannot cancel module-level timers.

**Suggested fix:** When a suite shows a failure that passes with `--filter`, fix the earliest failing test first and treat later failures as possible cascades; prefer resolving DOM handles at schedule time only where re-resolution is not the point under test.
