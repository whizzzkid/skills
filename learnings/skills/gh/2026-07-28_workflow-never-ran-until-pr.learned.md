---
skill: wk-gh
date: 2026-07-28
type: surprise
severity: high
verified-against-source: yes
---

CI jobs added on a feature branch had never executed once before the PR opened, and their first real run failed three separate ways.

**What happened:** Several new workflow jobs were committed, reviewed, documented as complete, and even added to branch protection while the branch was still pre-PR. The workflow's `on:` block was `push: branches: [main]` plus `pull_request:`, so no feature-branch push ever triggered it. The first execution — on PR creation — surfaced three genuine defects: a job that ran browser-backed unit tests without installing the browser, a marker parser that broke on the console output's surrounding quotes, and CI-runner-only startup noise the check treated as an error.

**Root cause:** Confirmed by reading the workflow's own trigger block: a workflow restricted to the default branch plus `pull_request` cannot run on a pre-PR feature-branch push, so nothing about the jobs was ever verified before they were marked done and made required.

**Suggested fix:** When a diff adds or edits a workflow job, verify the `on:` triggers actually fire for the current ref before treating the job as working; never mark such a job complete, add it to required status checks, or document it as green until a run exists for that ref (`gh run list --branch <branch>` returning nothing is the tell). A gate that has never executed is not a gate.
