---
skill: wk-workflow
date: 2026-08-28
type: correction
severity: low
verified-against-source: n/a
---

When fixing a false-positive class in a rule/check, propose suppressing the specific finding class, not a broad severity downgrade.

**What happened:** Asked to stop an LLM review check from flagging unverifiable "this name doesn't exist" claims, the agent's first proposal included downgrading such findings to `info` broadly; the user rejected it ("that would be incorrect") — the correct fix suppressed only the unverifiable existence-doubt class while leaving every other finding type and the severity ladder untouched.

**Root cause:** The proposal treated "reduce noise" as a severity problem instead of a scoping problem; a doubt the system can never resolve is noise at any severity, so the fix is class suppression, not downgrade.

**Suggested fix:** Add to proposal guidance: when a false positive stems from an unverifiable claim class, scope the fix to eliminating that class; reach for severity changes only when the finding is real but overweighted.
