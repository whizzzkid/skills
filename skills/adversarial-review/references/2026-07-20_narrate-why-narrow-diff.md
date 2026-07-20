---
class: principle
---

**Rule** — When dispatching the Step 3 fresh subagent on a merge-resolution or
narrowly-scoped bugfix (a handful of files), include a short prose paragraph
naming (a) which conflict side was kept and why, and (b) the exact defect
mechanism of the bugfix — then instruct the subagent to VERIFY those claims
against the diff, never assert them unchecked. Keep this to genuinely narrow,
mechanically-scoped reviews; a large/organic diff still needs the generic sweep.

**Why** — A bare diff forces the reviewer to reconstruct intent from context
before it can reason about correctness, spending its budget on "why" instead of
"is this right." Feeding the verified "why" directly redirects that budget toward
verification. No single narrative covers a large/organic diff, so the guard
holds only for narrow scopes.

**Where** — Step 3 "Fresh Adversarial Subagent" dispatch stance list.
