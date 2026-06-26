---
class: principle
---

**Rule:** When a spec introduces an event-sourced materialized-view / dual-write pattern
(a state table plus an append-only event log), the subagent must check four contract
failure modes that look like one:

- **Authority scope:** is "authoritative" scoped to mutations-only or all-writes? A
  creation baseline written straight to the table with no event breaks event-replay
  reconstruction.
- **Write-path enumeration:** is every write path (create, ingest, re-ingest, webhook,
  reaction) enumerated and assigned event-first or baseline-only? An undifferentiated
  re-ingest silently mutates user-facing columns outside the event log.
- **Atomicity vocabulary:** is "atomic" backed by an explicit transaction, not just the
  HTTP request boundary? Two sequential writes partially commit on crash, connection
  drop, or an unhandled exception between them.
- **Deterministic fold:** is fold/projection ordering deterministic under same-timestamp
  writes? `created_at` alone collapses; tie-break with `(created_at, id)`.

Re-ingest column categorization: identity/discovered-once (write-once when NULL),
always-refresh (overwrite every time), mutable user state (frozen on re-ingest, mutation
path only).

**Why:** Each failure mode looks small individually but compounds; one such spec needed
four adversarial-review iterations to fully correct.

**Where:** Step 2 sweep catalog row 2.9.2 (spec-shape sweeps).
