---
class: principle
date: 2026-05-19
---

- **Rule:** For dynamic-language source in the diff, grep every kept
  method call for a matching definition; flag calls whose definition is
  absent.
- **Why:** Dynamic loaders accept files where callers survive a
  deleted helper; runtime fails with `NoMethodError`/`NameError`. Pairs
  with sweep 2.7's inverse case (added params).
- **Where:** Step 2 sweep 2.17.
