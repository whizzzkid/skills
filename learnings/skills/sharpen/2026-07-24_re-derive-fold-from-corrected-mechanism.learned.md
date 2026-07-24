---
skill: wk-sharpen
date: 2026-07-24
type: pattern
severity: medium
verified-against-source: yes
---

Reproduction that contradicts the report yields a better fold than either the report or the
pre-verification draft — re-derive the edit from the source's semantics, don't patch the wording.

**What happened:** A field report described a chained byte-measurement and denylist-probe grep
being refused and inferred the cause as "compound-command shapes and quoting attract the block".
The report-is-hypothesis rule sent me to the guard's source and to a direct reproduction. Both
disproved the inferred mechanism, but the corrected one was also strictly more useful: the guard
applies its search-verb test and its out-of-repo-path test to the *entire* command payload, so a
compound call trips when one sub-command supplies the search verb and an unrelated sub-command
supplies the out-of-repo path — neither part blocks alone, and the path named in the block is not
the search's root at all. My pre-verification draft would have documented "the compounding itself
is the blocked element", which is vague; the source supported a deterministic rule instead — no
single call may hold both a search verb and an out-of-repo path — plus a second lever the report
had only guessed at, that the file-write guard warns rather than blocks, so staging scratch
through it leaves nothing to trip.

**Root cause:** The existing rule stops at "confirm a claimed cause exists in the source; delete a
documented cause the source disproves". It treats verification as a *filter* on the report's
mechanism — pass or delete — with no step that re-opens the edit once the real mechanism is in
hand. So the natural move after a disproof is to keep the drafted fold and correct its wording,
which silently inherits the report's framing and its vagueness.

**Suggested fix:** After a reproduction disproves or sharpens the reported mechanism, discard the
draft and re-derive the fold from the source's semantics before writing. A corrected mechanism
often changes *what the rule should say*, not merely how it is phrased — and frequently yields a
deterministic remediation where the report offered a heuristic one. Also worth stating: prefer the
formulation the source can be driven to demonstrate, since that is the one a future run can re-verify.
