---
skill: wk-gh
date: 2026-07-21
type: correction
severity: high
---

Editing a PR body with streaming BSD `sed` `i`/`a` one-liners silently blanked the body.

**What happened:** A pre-merge tweak to a PR description piped the body through `sed '/pattern/i...'` and `sed '$a...'` (GNU-style insert/append one-liners). On macOS/BSD sed these fail to parse (`command i expects \ followed by text`), producing no stdout, so each `BODY=$(echo "$BODY" | sed ...)` reassigned `BODY` to an empty string. The final `gh pr edit --body "$BODY"` reported success while overwriting the description with nothing — discovered only later via a re-fetch showing `body length == 0`.

**Root cause:** BSD sed `i`/`a`/`c` require a backslash-newline continuation, not the GNU inline form; a parse failure emits nothing rather than erroring loudly, and command substitution swallows the empty result. `gh pr edit` cannot distinguish an intentional empty body from a corrupted one.

**Suggested fix:** Build `gh pr edit --body` / `--body-file` payloads with a heredoc or a written file, never by streaming edits through `sed`/`awk`. Always re-fetch (`gh pr view --json body --jq '.body|length'`) after any body edit to confirm content survived — a "Body updated" message is not proof.
