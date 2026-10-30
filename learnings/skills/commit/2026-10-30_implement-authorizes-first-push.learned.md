---
skill: wk-commit
date: 2026-10-30
type: correction
severity: medium
verified-against-source: n/a
---

An "implement this" directive under wk-workflow authorizes the first push; do not pause to confirm.

**What happened:** After finishing an implementation the user requested, the agent stopped to ask before the first
push of a new branch with no PR. The user asked why it stopped.

**Root cause:** The first-push confirm gate's exception names only explicit "open a PR"-style directives, so an
implement directive under wk-workflow's mandated PR lifecycle read as ambiguous intent.

**Suggested fix:** In the first-push rule, state that any implementation directive running under wk-workflow is an
authorizing directive: push and invoke wk-pr without asking. Reserve the confirm for exploratory or
analysis-only sessions.
