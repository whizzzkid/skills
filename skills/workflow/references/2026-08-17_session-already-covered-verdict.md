---
class: one-off
---

# An all-already-covered retrospect: verdict record

**Scenario** — A retrospect carrying five corrective lessons across three skills
reached the sharpen queue after every one of them had already been folded.

**Symptom** — Nothing to distil. Without a record, a later pass re-derives the same
five verdicts from scratch, and the "escalate a repeat" rule looks applicable
because all five rules predate *this* pass.

**Fix** — Record the citation and the install time for each lesson, and archive the
retrospect. No skill edit, so no version bump.

| Lesson | Covering rule | Installed |
| --- | --- | --- |
| Speculated a shared-gem fix without checking sibling repos | fleet-first for shared integrations | 2026-08-14 23:41Z |
| Pushed code failing lint repeatedly | local lint before every push | 2026-08-14 23:41Z |
| Dropped an explicit mid-session request | enumerate every deliverable; mid-session asks are deliverables — act or track | 2026-08-14 23:41Z |
| Resolved a review thread before implementing the fix | only resolve threads you actually worked on — implement → commit → push → resolve | 2026-08-14 23:43Z |
| Used emoji text instead of the reactions endpoint | use the reactions API, not emoji text | 2026-08-14 23:47Z |

**Why not promoted** — No new principle. The one durable observation is procedural
and already encoded in the sharpen skill: every covering rule landed **23–29 minutes
after** the retrospect was written (23:18Z), so none of them steered the failing run.
That is `already-covered (unshipped)` five times over, and **no escalation notch is
owed** on any of them. Dating from history rather than assuming "older text = the
rule failed" is what keeps a same-day fold from being punished as a repeat.
