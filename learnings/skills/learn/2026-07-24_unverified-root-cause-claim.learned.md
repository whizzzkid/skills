---
skill: wk-learn
date: 2026-07-24
type: gap
severity: medium
---

The report template invites an asserted root cause even when the author never drove the
owning artifact, so a guess ships with the authority of a finding.

**What happened:** A field report claimed a shipped lexical guard hook blocked a
documented out-of-repo enumeration, and named *recursion* as the blocked axis. Driving
the hook directly disproved it: the recursive form passes, the non-recursive form
proposed as the remedy passes for an unrelated reason, and only a hand-expanded literal
path blocks. This is the **second** report disproved on that same axis; an earlier one
made a sibling claim and was likewise removed after checking the source. Both reports
filled in **Root cause** and **Suggested fix** in the declarative voice the template
models, with nothing distinguishing an inferred mechanism from a verified one.

**Root cause:** The template's `**Root cause:**` field has one slot and no provenance.
An author who only observed a symptom, then found a workaround, has no place to record
that the mechanism is a guess — so the guess is written as fact. The failure compounds
because a workaround that works reads as evidence for the mechanism it was chosen to
avoid, which is precisely the inference both reports made. Downstream, `wk-sharpen` must
spend a full verification pass per report to discover the claim is wrong, and a report
that slipped through unverified would degrade the artifact to route around a block that
was never there.

**Suggested fix:** Require provenance on any report naming a deterministic artifact
(hook, script, CI check, linter) — a `verified-against-source: yes | no` frontmatter
key, or an explicit `(unverified — inferred from symptom)` marker on the root-cause
line when the author did not read or drive that artifact. State in the template that a
working workaround is not evidence for the mechanism it avoided, and that "I could not
reproduce it another way" is a symptom, not a cause. Cheap to author, and it lets a
distillation pass triage which claims need verifying instead of treating every one as
authoritative.
