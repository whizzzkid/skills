---
class: principle
---

**Rule:** The canonical Step 4 footer covers every agent-authored outbound body
across all external systems — Jira issue/comment bodies (MCP
`addCommentToJiraIssue`/`editJiraIssue`), Slack messages, doc bodies — not only
GitHub. The owning skill injects it at render time. A terse factual lifecycle
comment is still an outbound body.

**Why:** A footer scoped mentally to GitHub PR/review/comment bodies let
non-GitHub connector writes (Jira comments) ship footer-less; GitHub comments in
the same session carried it, masking the gap.

**Where:** wk-gh Step 4 footer HARD RULE; cross-referenced by wk-jira top-level
footer HARD RULE for its MCP writes.
