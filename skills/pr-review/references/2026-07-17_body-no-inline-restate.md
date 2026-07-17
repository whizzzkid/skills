---
class: principle
---

**Rule:** The review body must not restate a finding already posted as an inline
comment. Diff each body paragraph against the inline `comments[]`; cut any that
duplicates one. The body carries only the verdict, change-spanning concerns with no
single inline anchor, and at most a one-line pointer to the key thread ("see the
L178 thread") — never a paragraph re-explaining an inline comment.

**Why:** The body is the verdict on the change as a whole, not an index of the
inline comments; restating each inline finding double-reports it, bloats the body,
and makes the reader read the same concern twice.

**Where:** wk-pr-review Phase 5 "Compose the review body."
