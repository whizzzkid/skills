---
skill: wk-workflow
date: 2026-11-20
type: correction
severity: medium
verified-against-source: yes
---

The agent deferred the one change that delivered the ticket's stated goal, calling it out of scope.

**What happened:** The ticket framed the problem as "CI never lints these files", but its task bullets named only a
lint-config include list. The agent found that CI runs no lint step at all. It did the bullets and listed the CI step as
a follow-up, so the merged change would still leave the files unlinted in CI. The user had to ask for it.

**Root cause:** The agent read the task bullets as the full scope and did not check them against the problem statement.

**Suggested fix:** In Phase 1, restate the ticket's problem as an outcome ("after merge, CI fails on a lint error in X")
and check the plan achieves it. A gap found mid-work that defeats that outcome is in scope: fix it, or ask, but never
defer it on your own.
