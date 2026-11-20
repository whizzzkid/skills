---
skill: wk-workflow
date: 2026-11-20
type: practice
severity: low
verified-against-source: n/a
source: learnings/retrospect/2026-11-20_session-4.learned.md
---

Browser-verify restore and persistence UX by counting network requests and checking a window marker, not DOM text.

**What happened:** A session-4 retrospect "what worked" bullet: verifying restore/persistence behavior by asserting
on network request counts and a page-level marker proved the state came from the cache rather than a re-fetch.

**Root cause:** DOM text is identical whether state was restored or re-fetched, so a text assertion cannot tell the
two paths apart.

**Suggested fix:** In the frontend live preview, back every restore/persistence/caching claim with a request-count or
window-marker assertion.
