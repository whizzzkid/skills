---
class: principle
---

- **Rule**: When the pending-review POST is classifier-blocked, persist the
  composed payload with the Write tool (not a bash heredoc/`jq > file`), then
  hand the user a `gh api … --input <file>` to post it.
- **Why**: The permission classifier matches on command *text*, not execution.
  Any bash command mentioning the blocked endpoint (`gh api
  repos/*/pulls/*/reviews`) re-trips the denial — even one that only writes a
  local file — so the work is lost unless saved via a non-bash tool.
- **Where**: wk-self-review Step 0.5 (pre-flight POST permission) / Step 4.
