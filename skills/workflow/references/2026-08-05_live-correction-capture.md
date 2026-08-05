---
class: principle
---

# Capture corrections before task continuation

**Rule** — A user correction, scope redirect, or self-caught error triggers
`wk-learn` immediately, before the agent continues the task. End-of-session
reconstruction is an audit fallback, not live capture.

**Classification** — `already-covered` re-violation. The live-capture rule and
retro-only-verifies clause shipped before this report, yet multiple corrections
were deferred to the retro. Escalate the rule from baseline prose to
`**Important:**` and make its continuation boundary explicit.

**Where** — `SKILL.md` → Mandatory Activation → live learning capture.
