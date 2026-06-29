---
skill: wk-adversarial-review
date: 2026-06-29
type: pattern
severity: high
---

A string-level HTTPS scheme guard on a curl URL does not protect redirect hops — add `--proto "=https" --proto-redir "=https"` when using `-L`.

**What happened:** A download command guarded the initial CDN URL with `start_with?("https://")` before passing it to `curl -L`. The sweep catalog's 2.58 rule flagged the string check as present, but the adversarial subagent surfaced that `-L` follows 30x redirects without re-checking the scheme. A redirect to `http://` or an internal host bypasses the guard entirely.

**Root cause:** Sweep 2.58 checks for the presence of an HTTPS scheme guard before a curl call, but does not verify the guard covers redirect hops. The string-level check is necessary but not sufficient when `-L` is used.

**Suggested fix:** Add a sweep step: whenever `-L` is present in a curl invocation that already has an HTTPS guard, verify that `--proto "=https"` and `--proto-redir "=https"` are also present. Flag absence as a blocker when `-L` and `-o` coexist (download to disk from a redirect chain is the highest-risk shape).
