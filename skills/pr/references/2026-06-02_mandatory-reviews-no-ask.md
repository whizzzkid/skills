---
class: principle
date: 2026-06-02
severity: high
slug: mandatory-reviews-no-ask
---

- **Rule:** Findings from any mandatory pre-flight review
  (`wk-adversarial-review`, `wk-arch-review`) are mandatory to incorporate
  without asking. After the review returns, immediately fix blockers, fold in
  improvements, and update the artifact under review (code, spec, or doc),
  committing each change via `wk-commit`. Never ask "should I fold these
  findings in?". Pause only for a single finding that needs a genuine design
  decision only the user can make — then ask that one specific design question.
- **Why:** Pre-flight reviews are mandatory; their findings are equally
  mandatory. Asking "want me to incorporate?" is friction without value — the
  agent ran the review precisely to act on it. Incident: after `wk-arch-review`
  on a spec, the agent asked "want me to fold these findings into the spec?";
  the user said review findings are always incorporated without asking. Same
  no-ask principle as drift sync, applied to the review gate.
- **Where:** Hard Rule 2 (Adversarial review gates every transition) — "No-ask
  on review findings".
