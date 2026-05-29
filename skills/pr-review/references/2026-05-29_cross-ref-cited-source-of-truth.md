---
class: principle
date: 2026-05-29
severity: high
---

- **Rule:** When a skill/config doc cites a live code file as authoritative,
  read that file and verify every stated constraint (allowlist entries, char
  classes, field names, enum values) against the live code on the current branch.
- **Why:** A doc that misstates an allowlist or schema ships a broken config at
  user-invocation time; PR-body disclosure does not fix the invoked artifact, and
  a claim may be satisfied only by a companion PR still open elsewhere.
- **Where:** Phase 4 "Documentation-only diff — substitute read-based analysis"
  (Cited source-of-truth audit bullet).
