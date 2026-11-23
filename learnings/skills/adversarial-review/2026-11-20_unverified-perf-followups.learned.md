---
skill: wk-adversarial-review
date: 2026-11-20
type: correction
severity: medium
verified-against-source: yes
---

Do not turn speculative performance "waste" into follow-up tickets until the request sequence is modelled or measured.

**What happened:** A review deferred a finding as a follow-up ticket. The finding said a client-side restore wasted
a request, because it cancelled the framework's in-flight request while a cached preview was rendering. A later
session implemented the proposed fix, then measured it in a browser. The fix doubled the completed requests and
added a flicker. The "wasted" request was being aborted early, and that was already the cheapest path. The ticket
was closed as won't-do after a full session of churn: implementation, tests, devcontainer, browser runs.

**Root cause:** The reviewer inferred the waste from reading the code. It never wrote out the request sequence
before vs after the proposed change, and never checked whether the "wasted" request completes or is aborted. The
acceptance criterion ("exactly 1 request") was unreachable under either design.

**Suggested fix:** Before raising or deferring a perf, request-count or latency finding, the reviewer must:
(1) write out the request/render sequence for the current code and for the proposed fix; (2) state whether each
"wasted" request completes or is aborted; (3) measure it (network log: finished vs aborted) or mark the finding
`unverified`. Without a sequence showing a net saving, drop the finding or label it a question rather than a
follow-up ticket. Check every acceptance criterion in the follow-up for reachability.
