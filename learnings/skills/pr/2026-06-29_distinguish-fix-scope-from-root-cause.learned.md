---
skill: wk-pr
date: 2026-06-29
type: gap
severity: medium
---

PR body must explicitly distinguish what the PR fixes vs. the root cause when they differ.

**What happened:** A security fix PR was opened for an app where the observable symptom (health-check returning non-200) had a different root cause (missing infrastructure secret). The user had to ask mid-session whether the code change would fix the health-check. The PR body described what the PR did, but buried the "this does NOT fix the health check itself" distinction in an infrastructure section the user had to find.

**Root cause:** The PR body template focuses on "what changed" but has no explicit prompt to state what the PR does NOT fix when the trigger symptom has a different root cause than the code gap being addressed.

**Suggested fix:** When a PR is triggered by an observable failure but the code change only addresses a related gap (not the failure's root cause), add a prominent one-liner near the top of the Summary: "Note: this PR does not fix {symptom} — that requires {infra/other work tracked in {ticket}}." Make this a required sentence whenever the PR's title implies a fix but the root cause is out-of-code-scope.
