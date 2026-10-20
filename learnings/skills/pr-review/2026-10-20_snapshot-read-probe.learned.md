---
skill: wk-pr-review
date: 2026-10-20
type: pattern
severity: low
verified-against-source: n/a
---

Prove "check-then-act" pre-check findings with a two-connection probe plus a mutant comparison.

**What happened:** A reasoning-only finding (a non-locking existence pre-check reuses a stale REPEATABLE READ snapshot inside an outer transaction, exhausting retries) was turned into evidence with a playground spec: one thread opens a transaction and reads, another commits a release, then the call runs; result compared on PR head vs. pre-check-removed mutant (error vs. success). Same harness also counted unique-index rejections under an 8-thread race (0 vs 8).

**Root cause:** n/a

**Suggested fix:** In Phase 3, for consistent-read vs. locking-read mixes, prescribe the outer-transaction stale-snapshot probe and a "revert the change" mutant run; restore the file with `git checkout --` afterwards.
