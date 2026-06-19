---
class: principle
---

**Rule:** The final adversarial-review gate before `gh pr ready` may be skipped when the *only* commits since the last `clear` verdict are direct mechanical responses to that verdict's own blockers (no new logic, no refactor, no scope addition). Note the skip and the cleared HEAD SHA in the PR. Any commit touching logic or adding behavior still requires re-running the gate.

**Why:** Re-running the gate against a delta that is purely the mechanical application of the verdict's own findings re-reviews changes the verdict already implied — wasted work with no new risk surface. The carve-out is narrow on purpose: a single logic/refactor/scope commit in the delta voids it.

**Where:** Step 5 "Final adversarial-review gate" in `SKILL.md` — the "Scoped skip — mechanical-only delta" note.
