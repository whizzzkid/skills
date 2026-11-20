---
skill: wk-commit
date: 2026-11-20
type: correction
severity: medium
verified-against-source: n/a
---

Agent ended the turn after committing, announcing "next: push + PR" instead of doing it.

**What happened:** Under an authorized workflow PR lifecycle, the agent committed, then wrote a summary listing push,
PR creation, and review as "next steps" and stopped. The user had to ask "what are you waiting for?".

**Root cause:** The agent treated the commit summary as a natural turn boundary; "push after every commit" was read as a
step to report rather than the mandatory tail of the commit action.

**Suggested fix:** Add to Pushing: "Never end a turn between commit and push (or between first push and `wk-pr`) when
authorized; a summary listing them as 'next' is a stall — run them in the same turn."
