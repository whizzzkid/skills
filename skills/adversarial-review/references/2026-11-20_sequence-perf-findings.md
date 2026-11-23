---
class: principle
skill: wk-adversarial-review
date: 2026-11-20
---

# Sequence a perf finding before raising or deferring it

- **Rule:** Before raising or deferring a performance, request-count, or latency finding, write out the request/render
  sequence for the current code and for the proposed fix, state whether each "wasted" request completes or is
  aborted, and measure it (network log: finished vs aborted). Without a sequence showing a net saving, label it a
  `question` rather than a follow-up ticket, and check every follow-up acceptance criterion for reachability.
- **Why:** A deferred finding claimed a client-side restore wasted a request. The follow-up implemented the fix and
  measured it: completed requests doubled and a flicker appeared, because the "wasted" request was aborted early and
  was already the cheapest path. Its "exactly one request" criterion was unreachable under either design. A full
  session went to a won't-do ticket.
- **Where:** `SKILL.md` → Step 4 (Findings Format and Severity).
