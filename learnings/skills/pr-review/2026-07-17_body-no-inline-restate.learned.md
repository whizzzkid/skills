---
skill: wk-pr-review
date: 2026-07-17
type: correction
severity: medium
---

The review body must not restate findings already posted as inline comments — link/point to the thread instead.

**What happened:** The composed review body repeated the substance of two inline comments (the key-decision concern and the refresher-fan-out concern) as full paragraphs. The user deleted both paragraphs before submitting, keeping only the whole-change verdict.

**Root cause:** The body is the verdict on the change as a whole, not an index of the inline comments. Restating each inline finding in the body double-reports it, bloats the body, and makes the reader read the same concern twice — the inline thread is already the canonical place for that finding.

**Suggested fix:** In Phase 5 body composition, exclude any content that duplicates an inline comment's substance. The body carries only: the verdict state (first clause), change-spanning structural concerns that have no single inline anchor, and at most a one-line pointer to the most important thread ("see the L178 thread") — never a paragraph re-explaining it. Before posting, diff each body paragraph against the inline `comments[]`; if a paragraph restates one, cut it.
