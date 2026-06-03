---
skill: wk-workflow
date: 2026-06-03
type: correction
severity: medium
---

Don't hardcode an allowlist of external API field names — use the library's struct tags instead.

**What happened:** Added a 40-entry `validPermissionNames` map and a 40-case switch statement to validate GitHub API permission names. The user corrected this, pointing out that the hardcoded list would need updating every time the GitHub API adds or removes permissions.

**Root cause:** The adversarial review correctly identified a security concern (silent empty-struct producing a grant-all token) but the fix over-engineered the solution by duplicating knowledge that already exists in the go-github struct's JSON tags. The JSON tags are the authoritative source; a parallel allowlist is a maintenance trap.

**Suggested fix:** Before building a hardcoded allowlist for an external API's field names, check whether the client library's struct tags already encode that information. If so, use `json.Decoder.DisallowUnknownFields` to get validation for free — the struct tags become the allowlist, and any API additions are picked up automatically when the dependency is updated.
