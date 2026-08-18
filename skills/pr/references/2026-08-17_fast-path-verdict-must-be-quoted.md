---
class: principle
source: learnings/skills/pr/2026-08-17_auto-merge-before-review.md
date: 2026-08-17
severity: medium
escalation: re-violation, one notch — prose precondition to citable artifact
---

## A fast path's expensive precondition needs a citable artifact

The trivial-PR auto-merge fast path names two co-preconditions: a size threshold and
a clear adversarial-review verdict. An agent matched the size threshold, enabled
auto-merge, and never dispatched the review.

**Why it recurred:** the prose rule ("the verdict is a precondition, not a
formality") was already installed and still did not steer the run. Where a gate pairs
a cheap mechanical check with an expensive one, the cheap check is the one that gets
performed and the expensive one is the one that gets rationalized as satisfied. Prose
emphasis cannot fix this, because the agent is not disagreeing with the rule — it is
never evaluating the second half.

**Escalation applied:** one notch, from prose precondition to a required citation.
The verdict must be quoted in the same response that enables auto-merge; nothing to
quote is itself the proof it was never dispatched. This converts an unobservable
mental check into an artifact present or absent in the transcript.

**Re-expressed for the target's installed model:** the report proposed verifying the
review "was invoked in the current session". This skill's installed rule holds that
clearance follows the reviewed body of work, not SHA or session identity, so a
session-scoped or SHA-keyed record check would contradict it. Quoting the verdict
carries the same evidentiary weight without importing a rival clearance model.

**Landed in:** `SKILL.md` Step 5 → "Trivial-PR auto-merge fast path".
