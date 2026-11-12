---
skill: wk-sitrep
date: 2026-11-12
type: pattern
severity: low
verified-against-source: n/a
---

A multi-day missed-end gap (unclosed day, then a holiday) is served by one fleet carrying explicit per-day windows.

**What happened:** The prior page was two calendar days stale and the day between had no work. Separate gathers per the
"older than previous workday" rule would have doubled the fleet; instead each agent got three half-open windows
(closed day, holiday, now) and returned open-now, per-day evidence, and carry-over status in one pass. The holiday
returned empty everywhere, so Yesterday fell back to the closed day. The page was then transformed in place with an
inline python filter keyed by `data-t` (drop, replace, append, insert, renumber, uniqueness assert); carried handler
bytes matched the canonical recipe. A browser screenshot with a relative filename landed under the repo root's
`.playwright-mcp/`, not the cwd.

**Root cause:** The rollover reference only describes sharing for the adjacent-day case; the gap case is unspecified.

**Suggested fix:** Document that a holiday between the closed day and today may share one fleet with per-day windows,
note Yesterday falls back to the last day with evidence, and tell callers where relative screenshot paths resolve.
