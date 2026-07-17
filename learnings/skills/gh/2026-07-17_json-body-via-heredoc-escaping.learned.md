---
skill: wk-gh
date: 2026-07-17
type: correction
severity: low
---

Manually escaping quotes/backticks inside a bash heredoc to build a `gh api` JSON request body caused an HTTP 400 ("Problems parsing JSON").

**What happened:** A `gh api repos/{owner}/{repo}/pulls/{n}/reviews` POST with a JSON body composed via a heredoc, with quotes and backticks hand-escaped for the review comment text, failed to parse server-side.

**Root cause:** Manual string interpolation into a JSON literal inside a heredoc is fragile — any unescaped or double-escaped quote/backtick in the comment body corrupts the JSON structure, and the failure only surfaces as an opaque parse error from the API, not a local syntax error.

**Suggested fix:** Build any non-trivial `gh api` POST/PATCH JSON body with `jq -n --arg key "$value" '{...}'` instead of heredoc string interpolation — `jq` handles all escaping correctly regardless of the body content.
