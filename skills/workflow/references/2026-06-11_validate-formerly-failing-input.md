---
class: principle
---

- **Rule** — After a normalization/transform feature, validate with at least
  one input that used to fail and must now pass — not positive cases only.
- **Why** — Positive-only validation passed while a wrong-casing input still
  failed; only a once-failing case turned passing proves the transform applied.
- **Where** — Phase 3 Verification, "Validate transformations with a
  formerly-failing input".
