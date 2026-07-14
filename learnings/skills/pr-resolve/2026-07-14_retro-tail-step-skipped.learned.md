---
skill: wk-pr-resolve
date: 2026-07-14
type: gap
severity: low
---

Under Auto Mode, the Step 11 retro tail-step was skipped as opt-in until the user asked why it hadn't run.

**What happened:** An autonomous full-cycle `pr-resolve` run completed push, replies, thread resolution, and CI verification, then stopped without invoking the retro — reasoning that retro is user/stop-hook triggered. The user had to prompt "why was the retro not requested?" to surface it.

**Root cause:** The skill lists retro as a tail step but does not say whether an autonomous (Auto Mode) run should auto-invoke it or may defer. The agent defaulted to defer silently, which reads as an omission rather than a decision.

**Suggested fix:** State explicitly in the resume/tail-step guidance that a full-cycle autonomous run must either invoke the retro or announce it is deferring and why — never silently skip a listed tail step.
