---
class: principle
date: 2026-06-15
---

# Delegate deep investigation to wk-adversarial-review

**Rule:** pr-review does not re-derive deep code investigation or playground
validation. Phase 3 invokes `wk-adversarial-review` on the checked-out PR and
consumes its structured findings (`severity`/`file`/`line`/`category`/`finding`/
`rationale`/`fix-sketch`) and verdict; the verdict is advisory (pr-review always
proceeds to compose comments). The mechanical sweep catalog, fresh adversarial
subagent, runtime matrix, mutation testing, specialized checks, and doc/prose
read-based analysis now live in adversarial-review.

**Why:** The two skills had large overlapping investigation/playground sections;
duplication drifts and bloats. A single owner for the investigation engine keeps
both skills under the 24 KiB ceiling (pr-review 31.8k → ~19.9k) and ensures one
canonical place to evolve sweeps.

**Where:** Phase 3 "Adversarial Investigation — delegate to wk-adversarial-review".
The gate-survival-by-substance learning that originated here is folded into
adversarial-review Step 5.
