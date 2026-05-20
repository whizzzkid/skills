---
name: github-write-routing
description: All GitHub-visible writes from any skill route through wk-gh's conventions for scoping and footer.
class: principle
---

- **Rule:** Skills that produce GitHub-visible content
  (PR title/body, review body, inline comments, replies, issue
  comments, thread resolutions) route through `wk-gh` rather than
  reimplementing scoping or footer logic locally.
- **Why:** Per-skill footers drift, miss surfaces, and fragment
  attribution. A single canonical surface keeps every outbound
  message consistent and auditable, and makes the next sweep —
  e.g., changing the feedback channel — a one-file edit instead of
  a cross-suite rewrite.
- **Where:** `wk-gh` Step 3 (write-surface routing) and Step 4
  (footer); each consuming skill carries a HARD RULE pointer back
  to those steps at the top of its rules section.
