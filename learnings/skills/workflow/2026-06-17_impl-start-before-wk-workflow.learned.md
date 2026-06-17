---
skill: wk-workflow
date: 2026-06-17
type: correction
severity: high
---

Agent announced "Starting implementation now" and began writing code before invoking `wk:workflow`; user interrupted.

**What happened:** After a planning exchange, the agent moved directly into file edits without first invoking the `wk:workflow` skill. The user interrupted with `[Request interrupted by user]` at the moment the agent announced it was beginning implementation.

**Root cause:** The agent treated the planning discussion as a substitute for the mandatory `wk:workflow` invocation. It reasoned (implicitly) that the plan was already established and the skill invocation would be redundant. The CLAUDE.md rule ("STOP. Before any development task, invoke `wk:workflow`") does not permit this rationalization.

**Suggested fix:** Add an explicit enforcement note to `wk:workflow`: "A planning discussion in chat is NOT a substitute for this invocation. Even when the plan is clear, invoke the skill — it may surface guardrails, branch hygiene checks, or pre-flight steps the conversation did not cover. The invocation gates the first Edit/Write/Bash call, not the plan."
