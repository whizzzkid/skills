---
class: principle
---

# Live learning capture — escalated to rung 3

**Rule** — Unchanged in substance: invoke the learn skill immediately when a user
correction, scope redirect, or self-caught error occurs, before continuing the task
or ending that response. Escalated in emphasis only.

## Escalation record

- A session took **three** user corrections and captured none live; all were
  reconstructed during the retro scan. Not an edge case — a total miss at every
  correction point.
- Rule installed 2026-07-30, report 2026-08-13 → live during the failing run.
- No positive-steering evidence blocked the notch: that session's "What worked"
  bullets covered an adversarial-review catch, a content-script init fix, and a
  manifest-command rename. None concerns capture.
- Escalated exactly one rung: **2 (`**Important:**`) → 3 (`**Very important:**`)**.

## Deferred framing addition — land this next, with a reclaim

The bare notch is the weaker half of the fix. The likely mechanism is
**recognition**, not priority: the rule fires on "a user correction", and an agent
mid-task does not always classify a politely-phrased redirect as one. The addition
worth making is an explicit recognition cue — a correction is any user message that
redirects, contradicts, or re-does the agent's work, however politely phrased.

It was **not** added in this pass because the body sat ~175 B from the size
ceiling, which put a ~100 B clause outside the drafting budget, and the reclaim
hunt over this file had already been run twice in the same drain with no exact
duplicate sentences left. Recorded here so the next pass lands it deliberately
after finding reclaim room, rather than re-deriving the same conclusion.

## Two sibling lessons from the same source were already covered

- *Fix targeted a plausible-but-wrong root cause* → the fix-symptom-match rule,
  folded 2026-08-13.
- *Two incorrect platform-API assumptions* → both generalized in the linked
  platform-API traps reference: a convenience API silently taking exclusive
  ownership of an event handler, and a gesture-context call broken by an
  `await` before it. Correctly generalized away from the specific vendor API.
