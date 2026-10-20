---
class: principle
source: learnings/skills/pr-review/2026-10-20_real-connection-race-harness.learned.md
date: 2026-10-20
skill: wk-pr-review
---

**Rule** — Prove a lock, deadlock, or race finding with a harness that uses real separate DB connections and
transactions, and compare the result against a mutant (lock variant or reverted change).

**Why** — Transactional-fixture specs run on one connection inside one snapshot, so cross-transaction lock
interactions are invisible to them: a mutation that dropped the lock stayed green. Such a spec reads as empirical proof
while being structurally unable to fail. Only concurrent connections (a winner holding an uncommitted conflicting
write, N losers in their own outer transactions calling the real method) exercise the claim, and the mutant comparison
shows the probe can see the effect at all.

**Where** — `SKILL.md` → Phase 3, under the HARD RULE "logic-bearing findings need empirical proof".
