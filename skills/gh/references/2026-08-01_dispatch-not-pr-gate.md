---
class: principle
---

# Dispatch success is not pull-request gate success

**Rule** — Treat a successful `workflow_dispatch` run as commit-execution evidence only. Prove merge readiness from
the live pull request's `headRefOid`, `statusCheckRollup`, and `mergeStateStatus`.

**Why** — A pull request created or updated with the repository `GITHUB_TOKEN` produces approval-required
`pull_request` runs for `opened`, `synchronize`, and `reopened`. A dispatched run can finish while the
pull-request-context gate remains pending.

**Where** — [`wk-gh`](../README.md), *A run must prove the pull-request gate*. Surface the pending approval, or use a
GitHub App installation token or personal access token when PR-context CI must start unattended.
