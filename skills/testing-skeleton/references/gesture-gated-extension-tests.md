---
class: principle
date: 2026-07-28
severity: medium
---

# Exercise gesture-gated extension permissions

**Rule:** Before testing behavior gated by `activeTab`, trigger the extension's
real browser action or command through the browser protocol. Pair the
post-gesture assertion with a negative case that omits the gesture.

**Why:** Opening an extension popup URL directly does not grant `activeTab`.
Waiting for permission-gated injection after direct navigation therefore times
out even when the end-to-end extension path works.

**Where:** Real-browser extension tests. Direct popup navigation remains valid
for behavior that does not depend on a user-gesture permission.
