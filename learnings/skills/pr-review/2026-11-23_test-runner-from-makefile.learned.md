---
skill: wk-pr-review
date: 2026-11-23
type: gap
severity: low
verified-against-source: n/a
---

Resolve the repo's test command from its Makefile/CI before the claim-replay run.

**What happened:** The light-mode replay of a "N tests" claim first tried `pytest`, which was not installed; the
repo's `make test` target used `python3 -m unittest`. The rerun found more tests than the description claimed (stale
count after follow-up commits).

**Root cause:** The skill says to replay empirical claims but does not say to read the repo's documented test entrypoint
first, so the single allowed `light` run can be spent on the wrong runner.

**Suggested fix:** In Phase 1 claims, add: read the test entrypoint (Makefile target, CI step, package script) before
the replay; a failed runner invocation does not count as the claim's one run. Also note that test-count claims go stale
across fix-up commits, so check them at the head commit.
