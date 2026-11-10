---
skill: wk-pr-review
date: 2026-11-10
type: pattern
severity: low
verified-against-source: n/a
---

A required check that is PENDING at Phase 1 can be SUCCESS by Phase 5; re-query the rollup right before the approve gate.

**What happened:** The Phase 1 snapshot showed the required CI status pending. Re-querying immediately before posting showed it green, so the approve gate passed. Judged on the stale snapshot, the review would have been held as pending.

**Root cause:** Phase 1 data was being reused at gate time.

**Suggested fix:** In the approve gate, require a fresh `statusCheckRollup` query plus the branch's required-status list, run in the same step as the head recheck. Treat pending as "not failing", but name it in the terminal.
