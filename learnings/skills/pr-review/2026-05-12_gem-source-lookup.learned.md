---
skill: wk-pr-review
date: 2026-05-12
type: pattern
severity: medium
---

Fetch framework gem source via `gh api repos/{owner}/{repo}/contents/{path}?ref={tag}` when bundler is unavailable locally.

**What happened:** The review required reading `RubyLLM::Tool#call` source to verify `Tools::Base`'s override assumptions. `bundle info`, `gem which`, and `find` all failed because gems were not installed in the worktree's environment.

**Root cause:** Isolated worktrees often lack a fully-installed bundle. `gh api` with base64-decode is a reliable fallback for open-source gems.

**Suggested fix:** Add a "gem source lookup" step to Phase 3 instructions: when a framework method is the subject of the review and `bundle show` fails, fetch the gem source via `gh api repos/{gem-owner}/{gem-repo}/contents/{path}?ref={version}` and pipe through `base64 -d`.
