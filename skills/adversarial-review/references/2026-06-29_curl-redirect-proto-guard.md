---
class: principle
---

**Rule:** A string-level `https://` scheme guard on a curl URL protects only the
initial request, not redirect hops. When `-L` is present, also require
`--proto "=https" --proto-redir "=https"`. Treat absence as a blocker when `-L`
and `-o` coexist (a redirect-chain download to disk is the highest-risk shape).

**Why:** `-L` follows 30x redirects without re-checking the scheme. A redirect
to `http://` or an internal host bypasses a guard that only validated the first
URL — an SSRF / downgrade vector that the string check appears to cover.

**Where:** Sweep 2.58 in `SKILL.md` — the curl/fetch SSRF row. The scheme-guard
check is necessary but not sufficient once `-L` is used.
