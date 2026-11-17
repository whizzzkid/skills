---
skill: wk-sitrep
date: 2026-11-17
type: gap
severity: medium
verified-against-source: n/a
---

Per-agent carry-over rechecks run out of read budget when the whole prior-page index is handed to every agent.

**What happened:** A rollover run gave each gathering agent one compact index of ~150 prior items and asked it to
re-check every item tied to its domain. One agent verified only a handful of items before exhausting its budget and
reported the rest as unchecked, so most older items kept stale text.

**Root cause:** The brief asks for open-ended carry-over verification with no per-agent item subset or priority order.

**Suggested fix:** Pre-split the index by domain (and by age or priority) before dispatch, hand each agent only its own
subset with an explicit item cap, and put the highest-priority/oldest items first so the cap cuts the tail, not the head.
