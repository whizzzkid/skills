---
skill: wk-self-review
date: 2026-07-22
type: gap
severity: medium
---

When the pending-review POST is classifier-blocked, persist the payload with the Write tool — not a bash heredoc/jq command.

**What happened:** Step 0.5 warned the `POST /pulls/{n}/reviews` could be blocked in auto mode; it was. The fallback attempt to save the composed review payload to a file via a bash `jq … > file.json` command was ALSO blocked, because the command text still contained the `gh api repos/*/pulls/*/reviews` string and the classifier matches on command text, not just execution.

**Root cause:** The classifier pattern-matches the whole command string. Any bash command that mentions the blocked endpoint — even one that only writes a local file — trips the same denial. Step 0.5 documents the block but not a safe way to preserve the work.

**Suggested fix:** In Step 0.5 / Step 4, instruct: on a blocked POST, save the review payload via the Write tool to `/tmp/agent/gh/<owner>/<repo>/pulls/{n}/self-review.json` and hand the user a one-line `gh api … --input <file>` to post it. Never rebuild the payload in a bash command containing the blocked endpoint string — it re-trips the classifier.
