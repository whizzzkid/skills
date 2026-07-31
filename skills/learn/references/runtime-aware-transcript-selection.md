---
class: principle
date: 2026-07-29
severity: medium
---

# Select transcripts for the active runtime

**Rule:** Resolve the active runtime or accept an explicit transcript provider,
then select the current session before widening the search. If no matching
transcript exists, scan available current-conversation history and label the
result degraded.

**Why:** A transcript root and schema from one runtime can be absent while the
live conversation still contains actionable corrections. Treating that absence
as an empty scan silently discards evidence.

**Where:** Interruption and correction scans. Report an evidence gap—not zero
findings—when neither a matching transcript nor current-conversation history is
available.
