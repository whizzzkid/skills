---
skill: wk-adversarial-review
date: 2026-06-05
type: gap
severity: medium
---

New lefthook command tagged `pre-commit-and-pre-push` was missing the YAML anchor and pre-push wiring until caught by adversarial review.

**What happened:** A new lefthook hook was added under `pre-commit` with the tag `pre-commit-and-pre-push` but without a YAML anchor (`&name`) and without a corresponding entry under `pre-push`. The tag claimed dual-phase enforcement but the implementation only enforced at pre-commit.

**Root cause:** The sibling-script audit (sweep 2.2) did not include a check that verifies declared tags match the actual YAML structure across both hook phases in lefthook config files.

**Suggested fix:** Add a sweep that, when a new lefthook command declares the `pre-commit-and-pre-push` tag, verifies (a) a YAML anchor is defined on the pre-commit entry and (b) the anchor is referenced under `pre-push`. Flag as blocker when the anchor is absent.
