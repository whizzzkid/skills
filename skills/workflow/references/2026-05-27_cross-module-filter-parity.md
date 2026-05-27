---
class: one-off
---

- **Scenario**: Implementing a `count` / `gauge` metric that measures artifacts produced by another module (inline comments posted, findings emitted, events fired).
- **Symptom**: Metric systematically over- or under-counts; unit tests miss the drift because the producer is stubbed and the filter mismatch never manifests.
- **Fix**: Grep the producer module for its production filter; the metric's filter must be a subset of (or identical to) the producer's. Example: `inline_count` must exclude info severity because `ReviewPoster` excludes info from inline posting.
- **Why not promoted**: Narrow to metric-implementing code paths; most workflow runs do not touch producer/metric pairs.
