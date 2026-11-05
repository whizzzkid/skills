---
skill: wk-sitrep
date: 2026-11-05
type: pattern
severity: low
verified-against-source: n/a
---

Rebuilding a live page by transforming the closed prior page in place is faster and safer than regenerating every span.

**What happened:** After a missed-end close, the next page was built by editing the closed page with an inline script that drops, replaces, appends to and inserts spans by item id, then renumbers every id sequentially and asserts uniqueness. Carried text kept its escaped hash marks and handler markup untouched.

**Root cause:** Skill says to generate spans from a compiled list but gives no recipe for the common case where most items carry over unchanged.

**Suggested fix:** Document an id-keyed edit-then-renumber recipe for carry-over-heavy starts; note that a one-off script failing on a no-op substitution aborts before writing, so substitutions should assert on text that exists.
