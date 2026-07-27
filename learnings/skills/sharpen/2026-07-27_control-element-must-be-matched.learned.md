---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

A collation control's differing element must be present on **both** sides of the `comm`; an
element unique to one side makes the control dead while it still looks exercised.

**What happened:** Built the Source 3 collation control per the documented rule — "require
two arms differ", "make the differing element order-flipping, on the arm-under-test side" —
by appending two uppercase-initial paths (`Aaa…`, `ZZZ…`) to the listing only, leaving them
out of the marker. The sort-order check confirmed the flip was real: under `LC_ALL=C` the
uppercase entries sorted first, under `en_US.UTF-8` they interleaved, and the two sorted
files were provably different. Yet both arms returned the same count (pinned 2, mixed 2), so
the control was dead and could not have detected an unpinned `comm`.

Rebuilt with the uppercase entry present in **both** the listing and the marker, truth = 0
backlog. Arms then diverged: pinned 0, mixed 1 phantom row, and `grep -Fxq` confirmed the
surplus row was present in the marker, proving it false rather than a real finding.

**Root cause:** Verified by driving both arms over the same inputs, not inferred. A row
genuinely unique to one stream is emitted by *any* walk, correctly ordered or not — the
mis-walk cannot change a verdict that is right under every ordering. The defect only
manifests on an element present in both streams, where a bad collation causes `comm` to
mis-advance past its partner and emit a *matched* pair as "unique". The existing rule
constrains the element's ordering (must flip) and its side (arm under test) but never says it
must be a **matched pair**, so an author can satisfy every stated condition — including the
order-flip precondition — and still build a control that exercises nothing. The arms-differ
tripwire does not catch this: the arms agree, which the rule says means "rebuild", but the
order-flip check passes and reads as confirmation the control is live, so the two signals
point opposite ways and the misleading one is the more concrete.

**Suggested fix:** State the element requirement as a matched pair, not just an order flip:
the control's order-flipping element must exist on **both** sides of the comparison, with a
known truth value of zero rows, so a mis-walk converts a match into a phantom. Add the
distinguishing check — verify the flip *and* the arms-differ result, and treat "sorts differ
but arms agree" as proof the element is unique to one side rather than as a live control.
