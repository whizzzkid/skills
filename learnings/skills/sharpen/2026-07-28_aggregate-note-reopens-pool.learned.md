---
skill: wk-sharpen
date: 2026-07-28
type: pattern
severity: medium
verified-against-source: yes
---

An "every remaining candidate carries a note" pool-exhaustion record scores no
candidate, so re-testing individually reopens reclaim the skill had written off.

**What happened:** Step 7.5 measured 105 B of headroom before drafting, so the reclaim
hunt ran first. Grepping `references/` for stay-inline and rejected-relocation notes
surfaced a prior pass's record that the pool was exhausted because *every remaining
candidate carried a note* — the same record that pushed at least two earlier passes into
the tighten-the-addition fallback. Re-scoring candidates one at a time under the
cut-site-pointer shape reopened two of them: an inline elaboration whose linked reference
stated it in full (pointer kept at the cut site, −62 B) and an enumeration the linked
reference restates verbatim (−95 B). Net −157 B against a +130 B addition, ratio 1.21×,
so the fold landed without touching load-bearing content and without a second
measure-and-trim cycle.

**Root cause:** Confirmed against the reclaim reference, which already classifies
"grounds aggregate" as one of three patterns that do not survive re-testing and states
that a pool summary is never a per-candidate veto. The rule was present and correct; what
made it easy to skip is that a pool-exhaustion note *reads* like a completed search. Its
plain-language form asserts the conclusion the current pass wants ("nothing left to
reclaim") and buries the fact that no individual target was ever scored, so the cheapest
next move looks like the fallback rather than a re-scan.

**Suggested fix:** Nothing to change in the skill body — the aggregate-grounds rule and
the search order both fired correctly once consulted. Worth reinforcing only if a later
pass again reaches the fallback with an aggregate note as its stated reason: at that
point the fix is to make the note-writing rule ("name the edit shape it was scored
under, and score candidates individually") apply retroactively, i.e. treat any note
lacking a per-candidate score as absent rather than as a veto.
