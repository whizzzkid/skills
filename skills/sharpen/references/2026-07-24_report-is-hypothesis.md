---
class: principle
skill: wk-sharpen
date: 2026-07-24
severity: medium
---

- **Rule:** A field report's "Root cause" and "Suggested fix" are claims, not authority.
  When the learning concerns a deterministic artifact (hook, script, CI check), read that
  artifact's source — and reproduce the failure where cheap — before drafting the fold.
  Reject any fold that would relax a guard or check; hunt the correctness bug instead.
- **Why:** The reporter observed a symptom and inferred a mechanism. For a deterministic
  artifact the ground truth is cheaply readable and routinely contradicts the inference,
  so folding the reported mechanism encodes a wrong model into the skill. Worse, a
  symptom-driven suggestion often points at loosening the thing that produced the symptom:
  a guard that honors caller-supplied scope is weaker than one deriving scope from the
  environment, and forfeits the property that makes the guard un-rationalizable. Reading
  the source instead surfaces the real defect, whose fix usually sharpens the guard in
  both directions rather than loosening it.
- **Where:** Step 1 — "Root cause" reframed as a claim to verify, plus a HARD RULE
  requiring source verification before drafting and rejecting guard-relaxing folds.
- **Deliberately not promoted:** the source learning's own suggested fix — have the guard
  honor a caller-provided scope — was rejected for exactly the reason above. Recorded here
  so it is not re-proposed.
