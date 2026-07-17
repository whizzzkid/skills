---
skill: wk-pr-review
date: 2026-07-17
type: correction
severity: medium
---

Review claims must be explicitly attributed to the agent — "My agent validated / simulated / verified …", never bare first-person "I verified".

**What happened:** The review body and inline comments asserted findings as "I verified the claims," "Confirmed by simulation." The user edited every such phrase to "My agent verified …" before submitting, and asked that agent-produced evidence always be framed that way.

**Root cause:** The reviewer is posting on the user's GitHub identity. A bare "I verified X" reads as the human personally vouching for a check they did not run; the reader can't tell a machine-validated claim from a human judgement, which misattributes accountability.

**Suggested fix:** In Phase 4/5, render every evidence-backed claim with an explicit agent-attribution stem — `My agent validated …`, `My agent tried simulating and found …`, `My agent ran X and got …`. Reserve bare first-person for the human's own posture (e.g. "Approving with concerns"). Apply to both the review body and inline comment bodies. Distilled stems to reuse: "My agent verified <claim> against <source>", "My agent simulated <scenario> and found <result>", "My agent ran <tool> — <outcome>".
