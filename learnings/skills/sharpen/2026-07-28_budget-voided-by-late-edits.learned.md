---
skill: wk-sharpen
date: 2026-07-28
type: correction
severity: medium
verified-against-source: yes
---

The measure-before-drafting rule was followed once per file and then invalidated by every
subsequent edit to the same file, twice in one run.

**What happened:** A multi-file fold measured the target body, sized the addition against it,
and applied the relocation — correctly, landing 53 B under. Then six more small ordering edits
were applied to the same file without re-measuring; the body finished 69 B *over* the ceiling
and needed an unplanned reclaim hunt. The same thing recurred on a second file (18 B over),
which had never been measured before its first edit at all.

**Root cause:** Step 7.5 says "Measure the staged body BEFORE drafting any content-adding
fold" and "Revising either side after measuring voids it — re-measure." Both were read as
governing *the* fold — a single old/new pair — so a fold that decomposes into one large
relocation plus a tail of small same-file edits satisfied the letter of the rule once and then
drifted. Nothing framed the budget as a running total per file across the whole pass, and the
tail edits each looked too small to warrant a re-measure. The re-violation is that the voiding
clause already exists and still did not fire.

**Suggested fix:** Escalate the existing clause one notch: make the budget a per-file running
ledger that every edit to that file must debit, not a one-time arithmetic statement — measure
after the last edit to a file, before staging, and treat any file edited but never measured as
unbudgeted. State the ceiling headroom remaining after each edit group so the drift is visible
while it is still cheap. A multi-file fold needs one measurement per touched file at entry,
not only for the file the report named.
