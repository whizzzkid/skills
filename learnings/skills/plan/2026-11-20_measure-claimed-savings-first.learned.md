---
skill: wk-plan
date: 2026-11-20
type: correction
severity: medium
verified-against-source: yes
---

Measure a ticket's claimed request/latency saving before implementing it.

**What happened:** A ticket said that skipping a client-side restore during a framework's cached-preview render
would save a wasted request and leave exactly 1 document request. The fix and its unit tests went in first. A
browser network count made afterwards showed the opposite. Evaluating during the preview aborts the original request
early (1 aborted, 1 completed). Skipping the preview lets the original request complete and render a stale page
before the restore (2 completed, plus a flicker).

**Root cause:** The plan took the ticket's premise as true. It never modelled the request sequence or measured the
baseline. The framework's render order was read in source and confirmed.

**Suggested fix:** Step 0/1: when acceptance criteria assert a request-count or latency saving, write out the request
sequence before and after the change, and measure the baseline (network log, aborted vs finished) before drafting.
If the model contradicts the claim, raise it as `[HUMAN-IN-LOOP]` (fix, redesign, or close as working-as-intended).
An aborted request can be the cheapest path.
