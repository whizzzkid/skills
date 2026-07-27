---
skill: wk-sharpen
date: 2026-07-26
type: gap
severity: high
verified-against-source: yes
---

The memory-marker diff pins collation on the `sort` but not on the `comm`, so a shell with a
non-C ambient locale compares C-sorted input and silently mis-walks the merge.

**What happened:** The Source 3 procedure prescribes normalizing both sides (`sed` + `sort`)
and comparing with `comm`. `LC_ALL=C` is pinned only on the `sort`. When the ambient locale is
UTF-8, `comm` applies UTF-8 collation to input ordered under C collation. The two orders
disagree on case: C sorts an uppercase-initial filename before lowercase-initial ones, UTF-8
sorts it after. `comm` assumes both inputs are sorted under *its own* collation, so on the
first out-of-order pair it mis-advances one stream and emits rows that are present on both
sides. It exits 0 with no diagnostic.

**Root cause:** Verified by direct reproduction, not inferred. Driving the documented pipeline
against the real store: the un-gated listing (which includes an uppercase-initial
no-frontmatter resident) diffed against the marker returned **6** rows under the ambient
locale; the same two files re-run as `LC_ALL=C comm` returned **2**. The four extra rows were
proven present in the marker by exact-line match (`grep -Fxq`), so they were false backlog, not
a real gap. Pinning the sort is necessary but not sufficient — `comm` is a second consumer of
the ordering and carries its own locale.

Two properties make this hard to catch:

- **It is case-triggered.** Every entry whose name collates identically under C and UTF-8
  (all-lowercase names) produces a correct answer. The gated listing on this store was
  therefore correct *by luck*; only the un-gated control, which carried an uppercase-initial
  filename, exposed the defect. A green gated run is not evidence the pipeline is sound.
- **It fails silently in both directions.** rc=0, empty stderr. The observed direction was
  over-reporting (inflated backlog), but a mis-walk can equally skip a genuinely-absent entry
  and under-report — a false drain, which the skill already names as the worse failure.

**Suggested fix:** Pin `LC_ALL=C` on the **comparison**, not only on the sort — every stage
that depends on the ordering must share one collation, exactly as both sides must share one
path form. State it as a general rule: when a pipeline sorts under a pinned locale and then
feeds a collation-sensitive consumer (`comm`, `join`, `uniq`), pin the same locale on the
consumer. Note the case-trigger explicitly so a future run does not read a green all-lowercase
result as proof, and require the positive control to carry a mixed-case entry so the control
can actually exercise the ordering assumption.
