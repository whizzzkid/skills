---
class: principle
skill: wk-adversarial-review
date: 2026-06-09
severity: high
---

- **Rule:** When a diff adds a check for an error-carrying key against an
  external API response, verify the API's actual error schema before
  clearing it.
- **Why:** Asserting the wrong key (checking `error` when the API returns
  `{"message": ...}`) silently skips both the success and failure branch —
  no output renders, so the failure looks like a no-op.
- **Where:** Sweep 2.11 (External-call reproduction gate), "Error-schema
  verification" with `grep -nE '"(error|err|errors|message)"'`.
