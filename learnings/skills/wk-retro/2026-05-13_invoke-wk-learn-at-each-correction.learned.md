---
skill: wk-retro
date: 2026-05-13
type: correction
severity: medium
---

Invoke wk-learn immediately at each correction point, not only at retro time.

**What happened:** Three significant user corrections happened mid-session (sentinel design, artifact-proxy approach, stale self-review). Only two ad-hoc learning files were written, and neither was written via the `wk-learn` skill at the time of correction — they were written later in a retro pass, which required reconstructing context from memory.

**Root cause:** Treated learning capture as a retro-only activity rather than a real-time response to each correction. When corrections accumulate, reconstructing them later loses precision and some get missed entirely.

**Suggested fix:** When the user corrects an approach or the agent catches itself in an error, invoke `wk-learn <affected-skill>` immediately in the same response that acknowledges the correction. Do not defer to retro — retro refines and promotes; it should not be the first capture.
