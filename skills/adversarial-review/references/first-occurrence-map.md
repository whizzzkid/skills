---
class: principle
---

**Rule** — When a loop records a first-occurrence index in a map (`seen[key] = i`)
to warn on or deduplicate repeats, confirm the match path skips the assignment
(usually via `continue`). Require a test case with ≥3 occurrences of the same key.

**Why** — An unconditional `seen[key] = i` on every iteration advances the
"first seen" pointer to each new duplicate, so the third-and-later collisions report
the wrong origin index. A 2-occurrence test always passes because the pointer has only
moved once, so the bug class is invisible to it.

**Where** — adversarial-review source-diff sweep (dedup / warn-on-duplicate loops);
test-coverage audit for any deduplication function.
