---
skill: wk-adversarial-review
date: 2026-06-09
type: gap
severity: high
---

Flag any API token passed as a curl `-H "Authorization: Bearer $TOKEN"` argument — it is visible in `ps aux` to other users on the same host.

**What happened:** A skill instruction passed `BUILDKITE_API_TOKEN` directly in the curl `-H` argument. This is visible to `ps aux` on multi-user systems. The fix is to write the header to a `chmod 600` temp file and use `-H @file`.

**Root cause:** Sweep 2.1 (credential in stderr) greps for tokens in stdout/stderr, not in process arguments. A `ps aux` leak is a different exposure path not currently covered.

**Suggested fix:** Add a curl-specific check to sweep 2.1 or a new sweep: when a diff adds a `curl` call, grep for any `$VAR` or `${VAR}` expansion inside a `-H "..."` argument. Flag as blocker: use `-H @file` with a `chmod 600` temp file instead. Detection: `git diff | grep -nE 'curl.*-H.*\\$[A-Z_]+'`.
