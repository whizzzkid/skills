---
class: principle
date: 2026-05-29
severity: medium
---

- **Rule:** Judge an allowlist/permission/capability addition against the entries
  already present, not against an empty list. If the new entry is strictly less
  privileged than a sibling already allowed, say so in the review body.
- **Why:** Reflexive "added to allowlist = wider attack surface" framing is wrong
  when the new entry is strictly less capable than an existing one; anchoring the
  verdict to a sibling comparison pre-empts unfounded reviewer alarm.
- **Where:** Phase 3 "Allowlist and privilege changes — compare against siblings,
  not zero".
