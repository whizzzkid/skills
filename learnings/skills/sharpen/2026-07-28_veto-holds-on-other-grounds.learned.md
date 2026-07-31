---
skill: wk-sharpen
date: 2026-07-28
type: surprise
severity: low
verified-against-source: yes
---

Re-testing a relocation veto whose stated grounds have gone stale can still end in "veto
holds" — because an *independent* permanent ground applies that the note never recorded.

**What happened:** Under byte pressure the run evaluated relocating a Batch-mode
control-construction block (481 B, the largest single candidate in the pool). A recorded
reference note vetoed that relocation on **reachability** grounds. The skill classifies
reachability as the known instance of a *shape-contingent* ground — "rejected because the
surviving pointer would sit later, before cut-site pointers were understood as available" —
so by the letter of the rule the note was reopenable and had to be re-tested rather than
obeyed.

Re-testing it, the relocation was still refused, but on entirely different grounds: the block
is a **control-construction verification checklist**, and the ceiling rule protects a
verification checklist under *every* edit shape ("Those vetoes are permanent by design"). So
the outcome matched the note's verdict while invalidating the note's reasoning.

**Root cause:** Confirmed against the source — both the shape-contingent classification and
the permanent-protection list are stated in the byte-budget reference, in different sections.
The note recorded only the weaker, shape-contingent ground, so a later pass reading it either
obeys a stale reason (and never learns the durable one) or reopens the candidate and re-derives
the durable protection from scratch. Nothing prompts the note to be amended to the ground that
actually holds, even though the skill already requires amending a note in place when a fold
invalidates it.

**Suggested fix:** When a re-tested veto is upheld on a ground other than the one it records,
amend the note to state the **durable** ground and mark the stale one as superseded — the same
"rewrite the note to what now holds" discipline the skill applies to an adopted rejection,
extended to an upheld-but-mis-reasoned one. Also worth stating generally: a candidate can carry
more than one protection, so clearing the recorded ground is not clearance to relocate — re-check
the permanent-protection list before treating a reopened candidate as available.
