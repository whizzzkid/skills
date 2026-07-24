---
class: principle
---

**Rule** — A guard-refused command is rewritten by removing only the blocked element (an
out-of-repo temp path, a recursive flag). Keep the prescribed matcher, primitive, and
comparison. When a hand-rolled substitute and the prescribed method disagree, the substitute is
wrong until direct inspection of the underlying data settles it — never trust whichever ran most
recently. Never resolve a refusal by disabling the guard.

**Why** — The prescribed memory-marker diff (normalize both sides, `comm` over sorted lists,
each side staged in a temp file) reported every memory already distilled — correct. On re-scan
the same shape was refused, because the guard blocks a single compound command that combines a
recursive search token with an absolute path resolving outside the repo. Rewriting it as a
per-file `grep -qxF` loop to avoid temp files reported *every* memory un-distilled; direct
inspection of the marker disproved that. Swapping the comparison primitive makes the
substitute's own tooling difference indistinguishable from a real finding. The temp-file staging
is the part most likely to attract the block, so the refusal is a recurring condition, not a
one-off.

**Where** — General reshape discipline in the guard skill's false-blocks section (its
remediation home); the memory-marker-diff instance in this skill's Source 3 normalize bullet,
beside the existing "every memory un-distilled means format mismatch" sanity check that caught
the inversion.

**Rejected** — Nothing relaxed. The report's "never disable the guard" line needed no fold: the
existing rule against folds that relax a guard already covers it, and the guard's own skill
already forbids agent self-authorized opt-out.
