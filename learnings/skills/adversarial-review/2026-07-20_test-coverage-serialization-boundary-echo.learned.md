---
skill: wk-adversarial-review
date: 2026-07-20
type: pattern
severity: low
---

A warn+skip branch guarding an unjoinable producer→consumer echo went untested because every test's happy-path mock joined the map for every item.

**What happened:** A collector step warns and skips when a posted item is present in one collection but absent from a correlation map built by an upstream call. Every spec used a mock that minted a correlation id for every item, so the skip branch was never exercised — a bot test-coverage finding, not the general subagent, caught it.

**Root cause:** Happy-path mocks that always return a fully-populated correlation map hide the partial-join branch. The branch is only reachable when an upstream per-item rescue drops one item from the map while the consumer still sees it — a state the uniform mock cannot produce.

**Suggested fix:** When reviewing producer→consumer correlation code (map keyed by one call, consumed by another), check for a test that feeds the consumer a non-empty-but-incomplete map (bypasses the empty-map early return, omits one live item) and asserts the warn/skip fires with no downstream call. A uniform "every item joins" mock is insufficient coverage for the partial-join guard.
