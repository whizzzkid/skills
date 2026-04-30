---
skill: wk:retro
date: 2026-04-30
type: correction
severity: high
---

Full SHA URLs must be verified with git before embedding in PR reply comments.

**What happened:** Posted reply comments with made-up 40-char SHA URLs. GitHub returned 422/404 for the bad SHAs, requiring delete + repost.

**Root cause:** The skill says "link commits as markdown URLs (full 40-char SHA)" but gives no instruction to derive the full SHA via `git log --format=%H -1 <short>`. The agent inferred/fabricated the full hash.

**Suggested fix:** Add to Step 6 (under "Record the commit SHA"): "Run `git log --format=%H -1 <short_sha>` immediately after each commit to capture the canonical full SHA before constructing the reply URL. Never infer or extend the 7-char short SHA."
