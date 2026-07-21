---
class: principle
---

# Never build a PR body with streaming sed/awk; re-fetch to confirm

**Rule** — Build `gh pr edit --body` / `--body-file` payloads with a heredoc or a
written file, never by streaming edits through `sed`/`awk`. Always re-fetch after
any body edit (`gh pr view --json body --jq '.body | length'`) — a "Body updated"
message is not proof the content survived.

**Why** — BSD `sed` `i`/`a`/`c` require a backslash-newline continuation, not the
GNU inline form; a parse failure emits nothing rather than erroring, so
`BODY=$(echo "$BODY" | sed …)` silently becomes an empty string. `gh pr edit`
cannot distinguish an intentional empty body from a corrupted one, so it
overwrites the description with nothing while reporting success — discovered only
via a re-fetch showing `body length == 0`.

**Where** — `wk-gh` Step 3 (canonical surface for GitHub writes).
