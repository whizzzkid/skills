---
skill: wk-pr-merge
date: 2026-08-01
type: gap
severity: medium
verified-against-source: yes
---

Require token boundaries when extracting ticket keys from outbound bodies.

**What happened:** The documented Jira scan matched `B2026-08` inside the
percent-encoded timestamp of the canonical outbound footer and initially
reported it as a linked ticket.

**Root cause:** The ticket regex has no left token boundary and scans
machine-generated footer text together with user-authored PR metadata.

**Suggested fix:** Strip the canonical footer before ticket detection and
require non-alphanumeric, non-percent token boundaries around Jira keys, with a
footer-timestamp regression case.
