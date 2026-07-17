---
class: principle
---

**Rule:** For spec/design-doc reviews, treat every claim about existing code
(named structs/fields, "reuses X", "within the existing Y", effort estimates like
"~N-line port") as Unverified until grep/read confirms it — delegate the batch to
one verification subagent. Doc-only diffs still owe this check. Re-verify a posted
finding the moment a later result contradicts it.

**Why:** Spec prose describing "existing" infrastructure is an assertion, not a
fact; a reviewer who takes it at face value inherits the author's error and
under-scopes downstream phases. A false "rides the existing concurrent fan-out"
claim became the second-strongest finding once ground-truthed.

**Where:** wk-pr-review Phase 1 — HARD RULE appended to the arch-review detection
block.
