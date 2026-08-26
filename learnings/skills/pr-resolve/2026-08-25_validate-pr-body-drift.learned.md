---
skill: wk-pr-resolve
date: 2026-08-25
type: gap
severity: medium
verified-against-source: n/a
---

Step 3 agent-observed drift check must validate PR body metadata against live state

**What happened:** PR body referenced a stale pre-release tag (alpha.2) when alpha.3 and alpha.4 existed. The drift check in Step 3 was skipped — the agent proceeded to conflict resolution without auditing the PR description against current releases/tags.

**Root cause:** Step 3 instructs injecting staleness as `surface: agent_observation`, but the agent prioritized the merge-conflict resolution (Step 2) and never circled back to validate the PR body content against live repository state (tags, releases, CI status, stacked-PR merge status).

**Suggested fix:** Add an explicit sub-step in Step 3 that queries `gh api repos/{owner}/{repo}/tags` and `gh api repos/{owner}/{repo}/releases` when the PR body references version tags or release links, and flags any mismatch as a drift finding before triage begins. The drift check should be non-skippable even when Step 2 consumes significant effort.
