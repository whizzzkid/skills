---
skill: wk-bk
date: 2026-06-17
type: surprise
severity: medium
---

bk build view --json outputs a Warning: line before the JSON when BUILDKITE_API_TOKEN env var is used

**What happened:** `bk build view --json 2>&1 | jq ...` failed with "Invalid numeric literal"
because the output started with `Warning: using BUILDKITE_API_TOKEN environment variable for
authentication.` before the JSON object, which broke jq parsing.

**Root cause:** When authenticated via env var rather than interactive login, `bk` emits a
warning to stdout (not stderr) that precedes the JSON payload. Piping directly to jq
without stripping this line causes a parse error.

**Suggested fix:** Always pipe `bk build view --json` through `tail -n +2` before `jq`
to skip the warning line. Add this as a canonical pattern in the skill's code blocks:
`bk build view -p <pipeline> -b <branch> --json 2>&1 | tail -n +2 | jq ...`
