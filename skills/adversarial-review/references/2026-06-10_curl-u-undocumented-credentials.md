---
class: principle
date: 2026-06-10
skill: wk-adversarial-review
---

- **Rule:** For every `$VAR`/`${VAR}` in a `curl -u`, `Authorization:`, or
  auth-passing pattern inside a doc shell fence, verify the variable is
  defined or annotated within the same doc; flag `suggestion`.
- **Why:** Ported snippets carry credential var names that were implicit in
  the source context but opaque in the new doc — copy-pasting users hit a
  silent auth failure.
- **Where:** Sweep 2.8 (Cross-doc enumeration sync), undocumented-credential
  bullet.
