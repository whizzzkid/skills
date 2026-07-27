---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

The Step 5 overfit-category scan is a hand-rolled multi-file grep too, but the exit-status
and per-file-quoting discipline is written only for the staged **path** scan — so the
category scan gets run with an unconditional "clean" banner.

**What happened:** Running the mechanical overfit scan, I built the file list as a single
space-joined shell variable and passed it unquoted-but-word-joined to `grep`, so grep
received one argument naming all five paths concatenated. Every category returned
`No such file or directory` on stderr and rc=2. My wrapper then printed its literal banner
— `(none above = clean)` — for all five categories, because the banner was an unconditional
`echo` after the grep, not a branch on the grep's status. Five categories reported clean
having read nothing.

It was caught only because grep's error text happened to be visible in the same output
block. A list that was well-formed but *wrong* (a stale path, a renamed file) would have
produced rc=1 and the identical banner, with no error text to notice. The rerun with a
`while IFS= read -r f` loop over one quoted path per invocation immediately surfaced a real
row the broken form had missed.

**Root cause:** Two rules that would have caught this exist in the skill and both are scoped
to the *other* scan. `staged-path-scan.md` says "Branch on the scan's exit status, never on
its warning text — rc=1 is 'read the input, matched nothing'; rc>=2 is 'never read it'", and
a distilled learning already covers the unquoted-multi-file-list false clean. But Step 5 runs
two hand-rolled scans: the staged **path** scan (which those rules name) and the **overfit
category** scan over the drafted edit text and reference files. Nothing routes the discipline
to the second one, and its bullet — "grep the edit text against the overfit categories" —
reads as a one-liner with no verdict protocol at all.

The general shape: a verification rule attached to one named scan does not travel to a
sibling scan of the same construction, even inside the same step. The skill has an analogous
rule for pins ("the pin is a property of each invocation, not of a named pipeline"), which is
exactly the missing generalization here.

**Suggested fix:** State the verdict protocol once as a property of **any** hand-rolled scan
this skill runs, rather than inside the staged-path-scan reference: one quoted path per grep
invocation via a read loop, and a verdict that branches on rc (rc=0 hit, rc=1 clean, rc>=2
never read the input → not a result). Then have both the Step 5 category-scan bullet and the
staged-path bullet inherit it. A printed "clean" that is not conditioned on the scan's status
is a banner, not a verdict.
