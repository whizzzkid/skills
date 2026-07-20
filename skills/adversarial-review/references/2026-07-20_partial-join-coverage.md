---
class: principle
---

**Rule** — When reviewing producer→consumer correlation code (a map keyed by one
call, consumed by another) with a guard that warns/skips on the partial-join
(item present in the consumer, absent from the map), require a test that feeds
the consumer a non-empty-but-incomplete map (omits one live item, bypasses the
empty-map early return) and asserts the warn/skip fires with no downstream call.

**Why** — Happy-path mocks that mint a correlation id for every item always join
the map, so the partial-join skip branch is never exercised. The branch is only
reachable when an upstream per-item rescue drops one item while the consumer
still sees it — a state a uniform mock cannot produce.

**Where** — Step 2 sweep 2.22 (structured-artifact plumbing / producer→consumer
wire).
