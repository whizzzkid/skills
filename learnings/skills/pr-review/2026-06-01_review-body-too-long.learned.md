---
skill: wk-pr-review
date: 2026-06-01
type: correction
severity: medium
---

Review body should mirror the author's review style — short, not a summarized investigation log.

**What happened:** Agent composed a multi-paragraph review body narrating what was verified (mutation tests, API contracts, return types). User stripped it to `LGTM 🚀` + footer on approval.

**Root cause:** Skill instructs the agent to write a "concise impression" but also lists things to include (what's strong, structural concerns, PR-too-large signal), which pulled toward a verbose justification of the LGTM verdict. The investigation detail belongs in terminal output for the reviewer, not in the GitHub review body the PR author reads.

**Suggested fix:** Add a hard constraint to the review body instructions: when the verdict is LGTM with no blockers, the body must be one line max (`LGTM 🚀` or equivalent). Multi-sentence investigation rationale stays in terminal output only — never in the GitHub review body. The body is for the author; the terminal summary is for the reviewer running the skill.
