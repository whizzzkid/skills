---
skill: wk-workflow
date: 2026-05-29
type: correction
severity: medium
---

Never ask the user if you should capture learnings — invoke wk-learn immediately after every skill run and after every correction.

**What happened:** After completing a skill run that produced multiple findings, the agent asked "Should I capture learnings for X and Y?" rather than capturing them unconditionally.

**Root cause:** The agent treated learning capture as an optional, user-confirmed step rather than a mandatory post-completion action.

**Suggested fix:** Treat wk-learn invocation as automatic and non-negotiable after any skill run or user correction — same as committing after a code change. Never surface it as a question.
