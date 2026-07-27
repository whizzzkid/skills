---
skill: wk-sharpen
date: 2026-07-25
type: gap
severity: medium
verified-against-source: yes
---

Step 3's prohibited-subject gate prescribes a hand-rolled denylist grep but carries no
pointer to the canary mechanics, so the Step 5 rule against pasting pattern source is
unread at the moment it first applies.

**What happened:** Step 3 directs the run to grep the learning's core subject against the
denylist before drafting. That check returned zero. Proving a zero requires a positive
control, so one was built by reading a denylist line and pasting it verbatim as the
subject — a regex shape like `foo[-_]?bar` used as literal text. The control failed and
printed a "matcher broken" verdict against a matcher that was fine. The correct
construction rule — expand the pattern to a literal it actually matches, never paste
pattern source — already exists, but lives in the reference that `SKILL.md` links only
from Step 5. At Step 3 it had not been read.

**Root cause:** The canary-construction mechanics are attached to the Step 5 staged-path
scan, while Step 3 independently prescribes a denylist grep of its own. Both steps
hand-roll a match against the same regex-bearing denylist and both therefore need a
positive control, but only one of them points at how to build it. Confirmed by reading
the gate's bullets: it names the denylist and the shape-matching hooks, and stops there.
The ordering guarantees the trap — the first hand-rolled denylist grep in a run is the
Step 3 one, so the rule is reached only after the mistake it prevents.

**Suggested fix:** Make the canary mechanics reachable from every step that prescribes a
hand-rolled denylist match, not just the staged-path scan — either point Step 3's gate at
the same reference, or state the expand-the-pattern rule once at the first place a
denylist grep is prescribed and cross-reference it later. A rule that only guards its
second occurrence does not guard the first.

**Corroborating note:** The equivalent zero-result checks in the same run that did carry
their controls inline (the ticket-shape scan, the parse gate, the hook loop) were all
controlled correctly on the first attempt, which isolates the failure to pointer
placement rather than to the operator skipping a known rule.
