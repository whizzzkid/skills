---
class: principle
source: source recount of the required-evidence enumeration against the agent rosters
date: 2026-08-18
severity: medium
---

## A required-set enumeration that shadows another list will drift from it

The abort rule defined required evidence as a prose list: messaging, mail,
calendar/meeting notes, tracker. Recounted against the rosters rather than read
through, that list matches the `start` roster exactly — five agents, four evidence
domains plus source control, correctly excluded. It does **not** match the `end`
roster, which launches seven agents and adds two further company-data evidence
domains. Neither is marked optional, and both feed the compile buckets.

**Consequence of the drift:** the rule governs publication in both sub-commands, so
under `end` two required-looking domains sat outside the required set. Losing them
entirely would not have tripped the abort, and the run would have published a page
missing evidence the same rule exists to protect. The prose passes every size and
link gate while being wrong.

**Fix:** derive the required set from the invoked sub-command's own roster rather
than restating it. A guard that reads its scope from the structure it protects cannot
drift from it; a guard that keeps a private copy of that scope always can. Adding the
two missing names would have fixed today's instance and left the mechanism intact for
the next roster change.

**Second drift found in the same pass:** the Quick Reference row still described the
abort as prompting, contradicting the rule's report-in-response requirement and the
standing ban on interactive triage. Corrected to state that it aborts without
publishing.

**Method note:** the count came from a probe shaped to the roster's own bullet markup
and proved to fire on a known roster member before its output was trusted. Reading the
prose and nodding would have confirmed it, since the list is internally plausible and
correct for the sub-command it was written from.
