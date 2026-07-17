---
skill: wk-plan
date: 2026-07-17
type: correction
severity: medium
---

Confirm ANY change is warranted before planning a fix when an investigation concludes "working as intended."

**What happened:** A debugging investigation traced a symptom (a CI review bot did not post an
auto re-approval) to a benign timing gap — a human approval landed after the bot's gate ran, and
nothing re-triggers the pipeline on a late approval. After the user chose a design option, I moved
straight into planning a messaging-only fix. The user pushed back ("wait, what is the fix here? if
we are not approving it, it should be ok?"), and the correct outcome was no code change at all —
close the ticket as Won't Do / working-as-intended.

**Root cause:** Step 0 grill treats the task as a fix to be scoped and skips the prior question of
whether a fix is warranted at all. When root cause is a false alarm, "do nothing / close as WAI" is
a legitimate — often the correct — outcome, but it was never surfaced as an option.

**Suggested fix:** In Step 0, when the investigated root cause is benign (correct behavior, external
timing, no defect), surface "no fix needed / close as working-as-intended" as an explicit
`[HUMAN-IN-LOOP]` option alongside any fix options, and confirm the user wants a change before
invoking the plan/implement flow. Do not default to planning a fix just because a ticket exists.
