---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

The rule that tells a run to honour recorded stay-inline notes never says those notes
expire when the technique they were scored under changes.

**What happened:** The reclaim search rule reads "Grep `references/` for a recorded
stay-inline / rejected-relocation note before proposing any relocation." Run plainly, that
turns every historical rejection into a permanent veto. This run found four relocatable
targets worth 298 B in a pool that two prior passes had recorded as exhausted — one of them
had explicitly recorded "every category-1 candidate carries a recorded stay-inline or
rejected-relocation note" and fell back to shrinking its own draft instead.

The only reason this run reopened them is that it happened to read an *amendment* appended
to one of those reference records, which states the exhaustion verdict was a mis-test:
the rejections were scored against candidate content at a time when the surviving pointer
was assumed to sit later in the body, before the cut-site-pointer shape existed. Nothing in
`SKILL.md` routes a reader to that amendment. A run that greps for the note, gets a hit, and
stops — exactly what the rule prescribes — never sees it.

**Root cause:** The grep rule treats a rejection note as a fact about the *target*, but a
rejection is a verdict about a target **under a particular edit shape**. When the available
edit shapes widen, every verdict scored under the narrower set becomes unsound, yet the
notes read identically before and after. The companion rule ("a target rejected purely on
reading order is mis-tested, not exhausted — re-test it under a cut-site pointer") does
exist and is what makes the reopening legal, but it is stated as its own bullet rather than
as a qualifier on the grep. The reader hits the grep first, gets a stop signal, and has no
prompt to carry on to the re-test rule.

**Suggested fix:** Qualify the grep rule at the point of the grep: a hit suppresses a
candidate only if the note records *why* it was rejected and that reason still holds under
the edit shapes now available — a note that does not state its grounds, or states grounds
scored under a narrower shape, is a re-test, not a veto. Consider also requiring a rejection
note to name the edit shape it was scored under when it is written, so a later pass can tell
a durable protection (a gate's enumerated checks, a verification checklist) from a
shape-contingent verdict without reading the whole record.
