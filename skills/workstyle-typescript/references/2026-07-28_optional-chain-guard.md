---
class: principle
---

# Narrow both nullish branches after optional chaining

- **Rule:** Before dereferencing an optional-chain result, exclude both `null`
  and `undefined`; a null-only guard is insufficient.
- **Why:** `?.` adds `undefined` when the base is nullish, while the queried
  property can still explicitly contain `null`.
- **Where:** [`wk-workstyle-typescript`](../README.md) Rules.
- **Verification:** A runtime proof exercised an explicit-null property and a
  null base, producing `null` and `undefined` respectively.
- **Budget:** Body `2406 + 189 = 2595` bytes, leaving 21,981 bytes.
