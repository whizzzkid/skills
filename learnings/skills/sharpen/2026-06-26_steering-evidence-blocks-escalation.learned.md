---
skill: wk-sharpen
date: 2026-06-26
type: pattern
severity: low
---

A learning that repeats an existing rule does NOT auto-escalate when same-session evidence shows the rule steered correctly.

**What happened:** A learning filed under skill A described a bot re-firing a
dismissed concern class across CI rounds. The behavior actually lives in caller
skill B, which already covers it. The companion retrospect's "What worked"
bullet explicitly stated the existing recognition "worked as intended." Classified
`already-covered` with no escalation, rather than forcing a byte-tight edit.

**Root cause:** The re-violation escalation rule reads "a fresh learning that
repeats an existing rule proves the rule is not steering → escalate one notch."
But that inference only holds when the rule *failed*. Positive steering evidence
(a retro confirming the rule fired correctly, or the learning itself noting the
outcome was correct) is the opposite signal — the rule worked; escalating would
inflate a rule that needs no change.

**Suggested fix:** In the re-violation escalation rule, add: before escalating an
`already-covered` repeat, check for same-session positive-steering evidence (retro
"What worked" bullet, or the learning conceding the existing behavior was correct).
Present → classify `already-covered`, cite the proving lines, do NOT escalate.
Escalate only when the repeat coincides with a fresh failure of the rule.
