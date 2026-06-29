---
class: principle
sweep: '2.58'
---

**Rule:** A URL/host value sourced from an external API response — even an
authenticated one — fed to `curl`/fetch (or any URL-accepting shell command)
without an `https://` scheme guard is an SSRF / local-resource-access vector.
Flag absence of the guard as a blocker, especially with `curl -L` (follows
redirects) or `-o` (writes to disk).

**Why:** Authentication proves the channel's identity, not the safety of the
response payload. A compromised or manipulated upstream can return a `file://`,
`gopher://`, or `dict://` URL, causing the fetch to read local resources or make
unexpected outbound connections. Trust in the auth was conflated with trust in
the content.

**Where:** Step 2 mechanical sweep catalog, row 2.58. The fix is a one-line
scheme guard (`start_with?("https://")` / `=~ /\Ahttps:\/\//`) before the call;
classify `obvious-fix` when no skip rationale exists.
