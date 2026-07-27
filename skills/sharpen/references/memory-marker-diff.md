---
class: principle
---

**Rule** — Normalize both sides before diffing the memory listing against
`.distilled-memories`: collapse repeated slashes (`sed 's#//#/#g'`) and `sort -u` each
side, then `comm`. Pin **one collation across every stage** — `LC_ALL=C` on the sorts
*and* on the `comm`:

```bash
sed 's#//#/#g' "$listing" | LC_ALL=C sort -u > a; sed 's#//#/#g' "$marker" | LC_ALL=C sort -u > b
LC_ALL=C comm -23 a b            # NOT: comm -23 a b
```

**Why** — `comm` does exact string matching, so the listing and the marker must share one
path form; a trailing-slash glob yields `dir//file.md` and silently mismatches every
entry. A result where *every* memory reads un-distilled is a probable format mismatch,
not a real backlog — sanity-check it before processing.

**On a refused invocation** — drop only the blocked element (stage both lists in-repo);
never swap the comparison primitive, or the substitute's tooling difference reads as real
backlog.

## A unanimous verdict indicts the tooling — both stages, both directions

- The two Source 3 stages fail in **opposite** directions, so neither warning generalizes
  to the other by analogy:
  - **Parse gate rejects every candidate** → under-reports. This is the worse failure: a
    false *empty* produces no visible work, so nothing prompts an investigation and the
    queue reads as drained.
  - **Diff shows every item un-distilled** → over-reports (probable path-format mismatch).
- Before a zero from a hand-rolled filter is allowed to close out a source, drive the
  filter against one input known to parse and confirm the count moves. An unverified zero
  is indistinguishable from a real drain.

## Gate the listing by parse-as-memory FIRST

- Require a frontmatter block carrying a `type:` key before a file counts as a memory —
  match it at column 0 *or* nested under `metadata:`; a bare `^type:` grep silently drops
  every memory that nests it.
- Non-memory residents (a hand-maintained index, another skill's append-only archive) are
  out-of-scope-by-rule, never backlog. Gate on this before diffing the marker.

- **Enumerate the accepted shapes from the store, not from the template.** The writer emits
  both a flat column-0 `type:` and a `metadata:`-nested `  type:`; a gate keyed on either
  form alone silently drops every memory written in the other. Templates lag the store, so
  the store is the authority for the shape list — never the documented example.
- **Build one positive control per shape, not one per gate.** A lone control synthesized by
  the gate's own author carries the same shape assumption the matcher does, so control and
  matcher share the defect and agree. Cover every accepted shape, plus one known non-memory
  that must be rejected.
- **Reconcile the reject list before calling the source drained.** Any rejected file whose
  name fits the memory naming convention is a reject to eyeball, not to trust.
  **Non-unanimity never exonerates the gate:** a shape-partial matcher splits *by
  construction* — it classifies the shape it knows and drops the shape it does not — so the
  more valid shapes the field has, the further the verdict sits from unanimous and the less
  the all-reject guard can see. A mixed verdict is a blind spot's signature, not evidence
  against one.

## Never mark what this run did not process

- `.distilled-memories` records **distillation**, not suppression. Adding an entry to
  silence a non-memory destroys the only way to tell a real completion from a skipped file.

## Pin the locale on the comparison, not only on the sort

- `comm` assumes both inputs are ordered under **its own** collation. Sorting under
  `LC_ALL=C` and comparing under an ambient UTF-8 locale feeds it input it considers
  unsorted → it mis-advances one stream on the first out-of-order pair and emits rows
  present on **both** sides. **rc=0, empty stderr, no diagnostic.**
- The disagreement is **case**: C orders an uppercase-initial name before lowercase-initial
  ones, UTF-8 after. So the bug is *case-triggered* — an all-lowercase listing collates
  identically either way and yields a correct answer. **A green run is not evidence the
  pipeline is sound**; it may be correct by luck.
- Therefore a mixed-case entry is **necessary but not sufficient**. Mixed case is the
  precondition for a collation difference, not the difference itself: `comm` still emits the
  correct rows as long as **each stream is walked under the collation it was sorted in**, so
  one locale applied uniformly to both sorts *and* the comparison is self-consistent
  whichever locale it is. A mixed-case control whose two inputs are ordered alike therefore
  agrees pinned-vs-unpinned and reads as proof the pinning is decorative.
- **Build the control so the two inputs *disagree*.** Sort the listing under the ambient
  UTF-8 locale and the marker under `C`, compare with `LC_ALL=C comm`, against a known truth
  value → fabricated backlog rows (against a truth of zero, a phantom row); pin both sides to
  one locale → the true count. Require the two arms to **differ**; arms that agree mean the
  control never exercised the bug and must be rebuilt before any conclusion is drawn.
- The load-bearing requirement is therefore **uniform pinning across both sorts and the
  comparison** — not the presence of mixed case.
- This dead control does **not** present as a zero: it can return a non-empty, correct-looking
  backlog identically in both arms, so the zero-based control tripwire never fires. Judge such
  a control by whether its arms diverge, never by whether it produced rows.
- It fails in **both** directions: the visible symptom is inflated backlog, but a mis-walk
  can equally skip a genuinely-absent entry and under-report — a false drain.
- Confirm a suspected mis-walk by exact-line match rather than re-reasoning about the diff:
  `grep -Fxq "$row" "$marker"` — a row the marker provably contains is false backlog.
- Generalize: when a pipeline sorts under a pinned locale and then feeds any
  collation-sensitive consumer (`comm`, `join`, `uniq`), pin the same locale on the consumer.
- **The pin is a property of each invocation, not of the named pipeline.** Every
  collation-sensitive comparison the run *creates* — ad-hoc reconciliation arms, control
  arms, one-off sanity checks — carries the same pin as the sorts feeding it, not only the
  invocation this snippet shows. The unpinned sibling is the dangerous one: a reconciliation
  arm exists precisely to validate the primary result, so leaving it unpinned puts a
  mis-walking comparison in the position of the check.
- **Converse tripwire:** a reconciliation result that contradicts a verdict the run already
  reached (a reject list naming files the run just accepted) indicts the reconciliation's own
  invocation form first, before the verdict it questions.

**Where** — wk-sharpen batch mode, Source 3 (global memory files).
