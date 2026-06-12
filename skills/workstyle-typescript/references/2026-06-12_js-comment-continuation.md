---
class: principle
date: 2026-06-12
---

- **Rule:** After editing a multi-line `//` comment block in JS/TS, verify
  every continuation line still starts with `//`.
- **Why:** A dropped `//` becomes a bare expression or label statement that
  `node --check` accepts as valid syntax but that throws at runtime.
- **Where:** wk-workstyle-typescript → Rules (continuation-line bullet).
