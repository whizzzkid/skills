---
skill: wk-adversarial-review
date: 2026-06-29
type: pattern
severity: high
---

CDN URLs from authenticated API responses still need HTTPS-only validation before curl.

**What happened:** A binary download used a `cdn_url` obtained from an authenticated upstream API response and passed it directly to `curl -L`. The adversarial review flagged this as an SSRF vector: if the upstream is compromised or returns a manipulated response, the URL could carry a `file://`, `gopher://`, or `dict://` scheme, causing curl to access local resources or make unexpected outbound connections.

**Root cause:** Trust in the API's authentication was conflated with trust in the response payload. An authenticated channel confirms identity but does not guarantee the response content is safe to act on without validation, especially for values that feed shell commands.

**Suggested fix:** Add the detection sketch to the sweep catalog: grep for any variable fed from an external API JSON field directly to `curl` (or any shell command accepting URLs) without a `start_with?("https://")` / `=~ /\Ahttps:\/\//` guard. Flag absence as a blocker when the curl invocation uses `-L` (follows redirects) or `-o` (writes to disk). The fix is a one-line guard before the call; classify it `obvious-fix` when no skip rationale exists.
