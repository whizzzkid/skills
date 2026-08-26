---
skill: wk-workflow
date: 2026-08-25
type: correction
severity: medium
verified-against-source: yes
---

Do not treat a user-supplied feedback artifact as an approved implementation plan.

**What happened:** The agent read a Markdown file containing raw review notes and treated the workflow rule that a
user-supplied plan is approved as sufficient authorization to begin execution. The user expected the agent to synthesize
and present a shipping plan first.

**Root cause:** The workflow distinguishes supplied plans from agent-authored plans but does not define the minimum
structure that makes an artifact an implementation plan. A filename and imperative feedback were mistaken for decisions
about scope, dependency order, commit boundaries, verification, and pull request strategy.

**Suggested fix:** Before applying the supplied-plan approval shortcut, verify that the artifact includes an implementation
sequence, dependency and scope decisions, acceptance criteria, verification, and shipping boundaries. Otherwise treat it
as requirements input, invoke planning, and wait for explicit approval of the synthesized plan.
