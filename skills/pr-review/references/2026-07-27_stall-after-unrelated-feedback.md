---
class: principle
date: 2026-07-27
severity: medium
---

# Stalling after unrelated process feedback — folded into wk-workflow

**Rule** — After a process correction that does not revoke the in-flight step, finish the
already-authorized action (posting a prepared pending review) in the same turn as the
acknowledgement, then adjust future behavior.

**Why** — The incident surfaced in a PR-review flow, but the defect is not review-specific:
nothing distinguished "acknowledge and adjust future behavior" from "acknowledge and also
finish the current, already-authorized action", so the agent conflated taking feedback
with pausing all forward progress and had to be told "why did you stop."

**Where it landed** — `wk-workflow` owns process conventions, so the rule is folded there
(Autonomy Rules row "Feedback lands mid-action", plus a stop condition beside the existing
"when soliciting feedback, block on it" rule). See
`skills/workflow/references/2026-07-27_finish-the-authorized-action.md`, which pairs it
with the same session's analysis-paralysis learning under one root cause.

Deliberately **not** duplicated into `pr-review/SKILL.md`: a general behavior rule
restated per-skill drifts, and pr-review is at its size ceiling. This record exists so a
later pass can tell "routed elsewhere" from "never processed".
