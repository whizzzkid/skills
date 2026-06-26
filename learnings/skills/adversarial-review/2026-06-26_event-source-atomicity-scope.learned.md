---
skill: wk-adversarial-review
date: 2026-06-26
type: pattern
severity: high
---

Docs/spec dual-write contract: "request atomicity" ≠ DB transaction; event-source authority must be scoped; re-ingest needs a three-class column split.

**What happened:** A spec document described a dual-write pattern (FINDING table + FINDING_EVENT log) with several imprecise claims that required four adversarial review iterations to fully correct.

1. Claimed "writes both atomically within the same request" — not atomic without an explicit DB transaction; two sequential InnoDB writes in one HTTP request can partially commit on process crash, connection drop, or an unhandled exception between them.
2. Claimed "FINDING_EVENT is authoritative" without scoping — the spec also showed creation state written directly to FINDING with no corresponding event, so event-replay could not reconstruct the full record.
3. Re-ingest path (known record hit via a repeat POST) was undifferentiated — it could have mutated user-facing state columns (status, reaction, response) outside FINDING_EVENT, silently bypassing the stated contract.
4. Drift detection fold specified ordering by `created_at` only — datetime granularity can collapse on same-instant writes; deterministic fold requires `(created_at, id)`.

**Root cause:** Event-sourcing contracts in specs are prone to three distinct failure modes that look like one: (a) authority scope ambiguity (creation vs. mutation), (b) write-path enumeration gaps (not all mutation sites listed), (c) atomicity vocabulary imprecision ("in the same request" vs. "in a transaction"). Each looks small individually but compounds.

**Suggested fix:** When a spec introduces an event-sourced materialized-view pattern, the adversarial subagent prompt should explicitly check:
- Whether "authoritative" is scoped to *mutations only* or *all writes* (creation baseline may be out of scope)
- Whether every write path (creation, ingest, re-ingest, webhook, reaction capture) is enumerated and assigned to either event-first or baseline-only
- Whether "atomic" is backed by an explicit transaction call (not just HTTP request boundary)
- Whether the fold/projection ordering is deterministic under concurrent same-timestamp writes
- Column categorization for re-ingest: identity/discovered-once (write-once when NULL), always-refresh (overwrite every time), mutable user state (frozen on re-ingest, mutation path only)
