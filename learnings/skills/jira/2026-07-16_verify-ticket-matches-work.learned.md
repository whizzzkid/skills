---
skill: wk-jira
date: 2026-07-16
type: correction
severity: high
---

A ticket key inherited from the branch/commits can reference unrelated work — verify the ticket's summary and status match the change before tagging a PR with it.

**What happened:** The branch and commit messages carried a ticket key that,
on inspection, pointed at an already-Done ticket for a *different* component
(the consumer service, not the pipeline emitter this PR implemented). A second
candidate key was also unrelated (a backlogged registration task). The PR title
and body were tagged with the wrong key until the mismatch was caught, requiring
a new correctly-parented ticket to be created and the references re-pointed.

**Root cause:** The Jira-key detection step lifts the first `[A-Z]+-\d+` from the
branch/commit without checking that the ticket's summary/component actually
describes the work in the diff. An inherited or copy-pasted key is trusted
verbatim.

**Suggested fix:** After detecting a Jira key, fetch the issue and confirm its
summary/component/status plausibly matches the current change before writing it
into the PR title/body. On mismatch (wrong component, or a Done/closed ticket
for unrelated work), surface it and create/locate the correct ticket under the
right epic instead of tagging the stale key.
