---
skill: wk-gh
date: 2026-08-14
type: correction
severity: medium
verified-against-source: yes
---

Use GitHub reactions API for review comment feedback, not emoji characters in reply text

**What happened:** When responding to {bot} review findings, agent embedded emoji characters (thumbs-up/down) in the reply comment text instead of using GitHub's native reactions API. User corrected: "why are you drawing emojis in comments and not responding to the original message with the correct reaction?"

**Root cause:** Agent treated "react with thumbs-up" as a text-formatting instruction rather than an API action. GitHub's reaction system is a distinct endpoint (`POST repos/{owner}/{repo}/pulls/comments/{id}/reactions` with `content: "+1"`) separate from commenting.

**Suggested fix:** When a review workflow asks to "react" to a comment, always use `gh api repos/{owner}/{repo}/pulls/comments/{id}/reactions -f content="+1"` (or `-1`). Never embed emoji Unicode characters in reply text as a substitute for native reactions.
