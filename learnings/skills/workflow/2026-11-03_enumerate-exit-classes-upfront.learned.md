---
skill: wk-workflow
date: 2026-11-03
type: gap
severity: medium
verified-against-source: n/a
---

When a fix promises "no path can leave X in state Y", enumerate every termination class up front, before the first push.

**What happened:** A "never block the merge" fix drew one new review-bot finding per push for six rounds: in-progress check on an unrescued exception, exits before the net registered, a fallback level, a crash's exit status, a crash after delivery misreported, and a signal turned into success.

**Root cause:** The invariant was patched path by path instead of being checked against a complete list of how the process can end.

**Suggested fix:** For any "every path" invariant, write the matrix first: deliberate exit (each code), uncaught exception, signal, refused/failed external update (once and twice), and before vs after the success write. Test each cell before publishing.
