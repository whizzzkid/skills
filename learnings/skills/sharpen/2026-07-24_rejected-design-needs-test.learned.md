---
skill: wk-sharpen
date: 2026-07-24
type: gap
severity: high
verified-against-source: yes
---

A reference file's recorded "deliberately not promoted" rejection is a coverage gap
to test, not prose to re-read — re-adopting the rejected design silently reverted a
guard while the full suite stayed green.

**What happened:** A learning asked for a guard hook to classify a search command's
arguments by role so a path-shaped *pattern* operand stops being charged as a search
root. Implementing that meant splitting the payload into command segments and
scope-checking only each search segment's path operands. A sibling reference file in
the same skill already carried a "Deliberately not promoted" note rejecting exactly
that design, naming the case it breaks: a `cd <outside> && <recursive-search> .`
shape, where the search names only `.` but a preceding directory change has moved the
effective root out of the repo.

The note was read before drafting and its rationale was understood, yet the
implementation still shipped the hole. The existing suite passed every case
(pre-change and post-change alike) because it had no case for the rejected shape —
the prior pass had recorded the rejection in prose and never encoded it as a test.
Driving the hook directly against the old and new versions with the same payload
showed the regression: the pre-change hook blocked, the new one allowed.

**Root cause:** Two gaps compound. A recorded rejection is stored as narrative in a
reference file, so nothing forces a later pass to *execute* the rejected case — and a
green suite reads as permission to proceed even when the suite provably never covered
the case the rejection names. Worse, the rejection was over-broad: only one shape
depended on cross-segment attribution, so the note read as "this whole design is
unsafe" when the accurate reading was "this design needs one compensating rule". A
later pass therefore faces a false choice between honoring a too-wide rejection and
silently re-opening the hole it protected.

**Suggested fix:** When an audit surfaces a `Deliberately not promoted` / `Rejected`
note covering the design about to be adopted, do not treat reading it as discharging
it. Extract the concrete case the note names, drive it against the artifact *before*
and *after* the change, and require the verdict to be identical; a suite that passes
without covering that case is evidence of missing coverage, not of safety. Land the
case as a test in the same pass, tagged so a future reader sees it is pinned
deliberately. When the rejected design is then adopted with a compensating rule,
rewrite the original note to say what actually holds — a stale blanket rejection
mislabels a solved problem as unsafe and will be either wrongly obeyed or wrongly
ignored.
