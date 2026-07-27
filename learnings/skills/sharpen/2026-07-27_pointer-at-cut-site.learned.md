---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

A relocation rejected for "moving the rule later in reading order" is legitimate when the
pointer is placed at the cut site, not left to a pre-existing later one.

**What happened:** Step 7.5 protects a rule whose full statement is reachable only through a
pointer appearing *later* in the body — cutting it inline would move it later in reading
order. Two prior passes applied that test to candidate reclaim targets, recorded the pool as
exhausted, and fell back to "tighten the addition until net goes non-positive"; one recorded
the >=1.2x planning ratio as unreachable at 1.02x.

This run hit the same wall with ~61 B of headroom, then found the test had been applied to
the wrong thing. The objection is not a property of the *content* being cut — it is a
property of *where the surviving pointer sits*. Relocating a block and writing the pointer
into the same bullet the block was cut from leaves reading order unchanged, so the rule is
reachable at exactly the position it previously occupied. That move reclaimed a net 201 B
from a target both prior passes had walked past, and let a 233 B fold land at net 0.

**Root cause:** The protection rule is stated as a property of the candidate ("its full
statement is reachable only via a pointer that appears later in the body"), which reads as a
fixed attribute to test and reject on. Nothing states that the pointer's position is a free
variable the author controls, so the reading-order objection gets treated as a verdict on the
target rather than a constraint on the edit's shape. Compounding it, the recorded
rejected-target notes preserve the verdict but not the reasoning's dependence on pointer
placement, so each later pass re-inherits the conclusion without the escape hatch.

**Suggested fix:** State the reading-order rule with its remedy attached: a relocation moves
a rule later **only if** the surviving pointer sits later — place the pointer at the cut site
and reading order is preserved. Before recording a reclaim pool as exhausted or declaring the
planning ratio unreachable, re-test every rejected target under a cut-site pointer; a target
rejected purely on reading order is not exhausted, it is mis-tested. Reserve the protection
for content that cannot be pointed at from its own position (a gate's enumerated pass/fail
checks, a verification checklist).
