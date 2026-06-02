---
class: principle
skill: wk-adversarial-review
date: 2026-06-02
severity: low
---

- **Rule:** On a spec/interface diff, flag a struct/union/record whose
  fields are read by multiple distinct modes or consumer families that each
  read only a subset. Trigger heuristic: ≥4 fields where prose/comments tie
  subsets to different modes (judgment, not pure grep). Raise as
  `suggestion` — ask whether compatibility should be explicit (consumer
  declares required fields, or producer declares supported consumers).
- **Why:** A flat multi-mode union slipped past the pre-flight review and a
  review-automation bot caught it. As modes grow, every consumer accretes
  nil-guards for inapplicable fields and compatibility stays implicit rather
  than declared. The mechanical sweeps had no lens for interface-abstraction
  smell in design docs.
- **Where:** Step 2 mechanical sweeps → "2.9.1 Multi-mode interface smell
  (spec/interface diffs)".
