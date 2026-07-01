---
skill: wk-workflow
date: 2026-07-01
type: correction
severity: medium
---

Agent asked "want me to capture a learning?" instead of auto-invoking the mandated learning-capture step at skill completion.

**What happened:** After the user corrected a mistake mid-run, the agent identified the correction as learning-worthy but ended its turn by offering to capture it ("want me to capture it?") rather than invoking the capture step. The user had to reply "why did you not capture it automatically?" to force the action.

**Root cause:** Post-completion learning capture is mandatory, not opt-in. A concise-mode reflex to end with a short offer collided with the standing rule, converting a required action into a permission request. Surfacing a mistake the user just caught is exactly the trigger for auto-capture.

**Suggested fix:** When a user correction or a mistake surfaces during a run, invoke the learning-capture step immediately as part of wrapping up — do not ask permission and do not defer it to a closing question. Offering-instead-of-doing is the anti-pattern; the mandate overrides brevity.
