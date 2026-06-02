---
class: principle
date: 2026-06-02
severity: high
slug: mandatory-reviews-no-ask
---

- **Rule:** Pre-flight review findings (`wk-adversarial-review` on code,
  `wk-arch-review` on specs/docs/plans) are mandatory actions, not options. Fix
  blockers and re-run the gate; incorporate improvements/gaps into the artifact
  and commit; for a genuinely design-ambiguous finding, ask the one specific
  design question, wait, then act. Never ask "should I incorporate these
  findings?".
- **Why:** An agent ran the gates then asked the user whether to incorporate the
  findings; the user clarified findings are always incorporated without asking.
  Framing incorporation as user-gated is the same autonomy violation as asking
  "should I commit?" — it wastes a turn for a non-decision. The only legitimate
  pause is a real design decision the user owns.
- **Where:** Phase 4 (Adversarial Review) → "After Verdict" → "Findings are
  incorporated, never offered" HARD RULE; extends the Autonomy Rules table to
  `wk-arch-review` and to the improvements/gaps path.
