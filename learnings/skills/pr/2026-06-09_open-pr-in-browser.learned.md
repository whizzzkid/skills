---
skill: wk-pr
date: 2026-06-09
type: gap
severity: medium
---

After creating a PR, open it in the browser automatically.

**What happened:** After `gh pr create` returned the PR URL, the skill reported the URL in text but did not open it in the browser.

**Root cause:** No step in the skill instructs the agent to open the newly created PR URL after creation.

**Suggested fix:** Add `gh pr view --web` (or `open <url>`) immediately after `gh pr create` succeeds, so the PR opens in the browser without requiring the user to click the URL manually.
