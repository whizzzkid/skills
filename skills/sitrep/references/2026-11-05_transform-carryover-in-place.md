---
class: principle
---

# Transform a carry-over-heavy page in place

**Rule** — Two additions to `start` Stage 4:

- **Mostly carry-over → transform, don't regenerate.** Edit the prior page in place keyed by `data-t` (drop, replace,
  append, insert), emit only new or changed spans from the inline generator, then renumber every `data-t` from `t1`
  and assert uniqueness. A carried span's handler bytes must equal the canonical recipe in
  [`checkbox-span-handler.md`](checkbox-span-handler.md); a mismatch regenerates that span.
- **Assert each substitution hit.** Every in-place substitution checks its target text exists before the write and
  aborts on a miss.

**Why** — After a missed-end close the next page was built by transforming the closed page: carried text kept its
`\#` escapes and handler markup untouched, so nothing had to be re-escaped or re-typed. Shell parameter substitution
on an absent target returns the input unchanged with no error, so a mistargeted patch silently writes nothing; the
reporting run's assertion aborted before writing. Renumbering is load-bearing: the toggle handler replaces the first
`data-t="tN" data-done=…` match, so a duplicate ID toggles the wrong span.

**Drift qualifier** — The 2026-10-28 ruling (prior page is never the preferred source of canonical markup) still
holds; the byte-equality check keeps a hand-edited prior page from propagating its drift.

**Where** — `SKILL.md` → `start` Stage 4 → *Mostly carry-over → transform the prior page*; *Patch lines without
eating `\#`* (substitution-hit assertion).
