---
class: principle
---

**Rule** — Pin one collation across **every** stage of a sort-then-compare pipeline, not
just the sort. In the memory-marker diff that means `LC_ALL=C` on the sorts *and* on the
`comm`.

**Why** — `comm` assumes both inputs are ordered under its own collation. C-sorted input
compared under an ambient UTF-8 locale is, from `comm`'s view, unsorted: it mis-advances one
stream at the first out-of-order pair and emits rows present on both sides, exiting 0 with no
diagnostic. The C/UTF-8 disagreement is on **case**, so the defect is case-triggered — an
all-lowercase listing collates identically either way and returns the right answer regardless.
That makes a green run worthless as evidence, which is why the positive control must carry a
mixed-case entry — **necessary but not sufficient, corrected by a later fold**: mixed case only
permits the disagreement, so the control must additionally order its two inputs under
*different* collations, and its two arms must differ. See
`2026-07-26_collation-control-must-disagree.md`. The failure runs both ways: the visible symptom is inflated backlog, but a
mis-walk can also skip a genuinely-absent row and under-report, which is the false-drain
direction the skill already treats as the worse one. Generalizes to any collation-sensitive
consumer (`comm`, `join`, `uniq`).

**Verified against source** — Reproduced directly against the real store, not inferred. The
un-gated listing (carrying an uppercase-initial no-frontmatter resident) diffed against the
marker returned 6 rows under the ambient locale and 2 under `LC_ALL=C comm`; the four extra
rows were proven present in the marker by exact-line match (`grep -Fxq`). The gated listing
returned 0 under both locales — correct by luck, since every accepted memory is lowercase.

**Rejected** — Did not "fix" this by dropping `LC_ALL=C` from the sorts to match the ambient
`comm`. Matching on the ambient locale leaves the pipeline hostage to whatever locale the
invoking shell happens to carry; pinning C on every stage makes the result independent of the
environment. Did not keep the failure-mode rationale inline in `SKILL.md` — the linked
reference is where the procedure and its failure modes live, so an inline copy is duplicated
by construction.

**Escalation** — None. This is a genuine gap, not a re-violation: the existing rule required
one *path form* across both sides and said nothing about collation, and the sort was already
correctly pinned.

**Where** — `SKILL.md` → Batch Mode, Source 3, the normalize-before-diff bullet; full
mechanics in `references/memory-marker-diff.md`.
