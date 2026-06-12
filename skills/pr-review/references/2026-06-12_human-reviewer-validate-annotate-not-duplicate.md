---
class: principle
---

# Validate human reviewers; annotate, comment only on disagreement

- **Rule** — Do not re-iterate findings other bots/humans already raised.
  Validate a human reviewer's concern against current code; if it holds,
  skip the parallel comment. When an independent finding agrees and touches
  the same code, annotate `Also fix concerns from @{reviewer}`. Comment
  only when findings disagree (correction + evidence).
- **Why** — A second voice agreeing is noise; the value is validation and a
  pointer, not a restatement.
- **Where** — Phase 5 "Deduplicate against existing comments" →
  "Duplicate of a human reviewer's comment". (Bot dedup already covered by
  the Phase 4 validation queue + Confirmed→silent-skip rule.)
