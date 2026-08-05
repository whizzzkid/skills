---
skill: wk-gh
date: 2026-08-01
type: correction
severity: high
verified-against-source: yes
---

A successful workflow-dispatch check suite on a pull-request head does not prove the pull request's required checks
are satisfied.

**What happened:** Automation updated a pull request with `GITHUB_TOKEN` and dispatched CI against the exact head.
All raw commit check-runs passed, but the pull-request rollup stayed empty and the ruleset kept the pull request
blocked; approving the automatic `pull_request` run immediately populated the rollup.

**Root cause:** GitHub intentionally puts `pull_request` runs caused by a `GITHUB_TOKEN`-created or updated pull
request into approval-required state. `workflow_dispatch` is a recursion-safe exception that runs on the commit, but
its successful check-runs did not satisfy the pull-request-context ruleset gate.

**Suggested fix:** For workflow-created pull requests, gate completion on the live pull-request rollup and merge
state, not raw commit check-runs. Use a separate GitHub App installation token or personal access token when
PR-context CI must start automatically; otherwise surface and approve the pending `pull_request` run explicitly.
