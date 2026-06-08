---
skill: wk-pr-review
date: 2026-06-08
type: correction
severity: low
---

Say "verified locally" not "verified in playground" in review comments.

**What happened:** Review comment bodies referenced the `.review-playground/` directory and described "playground experiments" — internal scaffolding that is meaningless to PR authors and exposes agent internals.

**Root cause:** The skill instructs the agent to build a playground and reference experiment outcomes in comment bodies, but doesn't constrain the vocabulary used when surfacing evidence to the author.

**Suggested fix:** When describing verification evidence in a GitHub review comment or review body, always say "verified locally" (or "verified against upstream source") rather than naming the playground directory, playground scripts, or any internal experiment artifact. The playground is an internal tool; the comment is author-facing.
