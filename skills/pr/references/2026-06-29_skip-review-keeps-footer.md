---
class: principle
---

**Rule:** `wk-gh` routing and outbound-footer injection are unconditional and
independent of every other gate. A user "skip the review" instruction waives
only the adversarial-review gate (Hard Rule 2); it never disables `wk-gh`
routing or the footer on any `gh pr create` / `gh pr edit` payload.

**Why:** The adversarial-review gate is separately waivable by the user, but the
footer is mandatory on every PR body. Conflating "skip the review" with "skip
`wk-gh`" ships a footer-less PR body — a high-severity correctness gap.

**Where:** `## Hard Rules`, Rule 0. State the independence inline so a
review-skip instruction cannot cascade into dropping the footer.
