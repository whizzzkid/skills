---
skill: wk-sharpen
date: 2026-07-28
type: gap
severity: medium
verified-against-source: yes
---

`grep -f <denylist>` consumes the denylist's **comment lines as patterns**, so a bare `#`
line matches any text containing `#` — a hand-rolled denylist scan reports a false hit.

**What happened:** The Step 5 mechanical overfit scan was hand-rolled as
`command grep -niEf .githooks/scrub-denylist.txt <edit-text>` and returned exactly one hit:
the reference file's markdown heading. Reconciling by iterating the denylist one pattern at a
time (skipping `#` and blank lines, the way the owning hook does) returned **no** match. The
two forms disagreed. Per the converse-tripwire rule the reconciliation's own invocation form
was suspected first, but here the disagreement indicted the *original* scan: `.githooks/
scrub-denylist.txt` contains standalone `#` lines as comment scaffolding, and `grep -f` has no
notion of comments — every line in the file is a pattern. The only line of the edit text
containing a `#` was the markdown heading, so it matched. The real gate, `scrub-staged.sh`,
strips comments before matching and passed cleanly.

**Root cause:** The skill already says "never reimplement their matcher" and "same flags ≠ same
engine", but it frames the governing risk as the false-*clean* (a hand-rolled scan missing a
real hit). This is the opposite failure — a false-*dirty* — and it is not named. A false hit is
less dangerous but still costs a diagnostic cycle, and worse, it trains the operator to
dismiss hand-rolled scan output, which erodes the false-clean warning too. The specific
mechanism (a pattern file whose comment syntax is meaningful only to its consumer, not to
`grep -f`) generalizes to any `-f` pattern file that carries comments or blank lines.

**Suggested fix:** In the Step 5 hand-roll rule, name both directions of the hook-vs-hand-roll
divergence, and note that a pattern file's comments and blank lines are inert to `grep -f`
(a blank line matches *everything*, a `#` line matches any text containing `#`). Prescribe
resolving any hand-rolled hit against the owning hook's verdict before acting on it, rather
than treating the hand-rolled scan as authoritative in either direction.
