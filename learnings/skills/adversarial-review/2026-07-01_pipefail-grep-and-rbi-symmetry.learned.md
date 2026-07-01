---
skill: wk-adversarial-review
date: 2026-07-01
type: gap
severity: medium
---

Two bot-caught classes the mechanical sweep should own: empty-grep under pipefail, and RBI sig sibling-symmetry.

**What happened:** An automated reviewer caught two Minor findings the adversarial sweep did not: (1) a `grep -E "pattern" file | sed` under `set -euo pipefail` that aborts the whole script when the file has zero matching lines (grep exits 1, pipefail propagates), while an identical grep a few lines above was already guarded with `{ grep ... || true; }`; (2) a Sorbet RBI method whose block param used `T.nilable(T.proc.void)` while sibling methods in the same class bound the block to a specific receiver via `T.proc.bind(SomeClass).void` — losing type precision inconsistently.

**Root cause:** No sweep row for "a guarded pattern applied inconsistently within one file." Both findings are asymmetry bugs: one grep guarded, a sibling grep not; one RBI sig bound, a sibling sig not. The sweep catalog checks individual shapes but does not systematically flag intra-file inconsistency of an established guard/type pattern.

**Suggested fix:** Add a sweep: for any `grep`/pipeline pattern that appears ≥2× in one shell script under `set -e`+`pipefail`, verify every instance carries the same match-failure guard (`|| true`). Add a parallel sweep for RBI/type-signature files: when sibling methods in one class bind a block/proc to a receiver type, flag any sibling that uses an unbound `T.proc.void`. Both are cheap intra-file symmetry checks that a general subagent misses because each line looks locally fine.
