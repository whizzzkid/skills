---
class: principle
---

- **Rule:** Sweep 2.4 (comment accuracy) now covers two classes: assertive behavioral claims (`always`, `guaranteed`, `never`, etc.) AND descriptive intent phrases (`treat .* as`, `interpret .* as`, `use .* to match`, `equivalent to`, `mirrors`, `behaves like`). Verify the described behavior still appears in the same function body.
- **Why:** Refactors often remove the described behavior but leave the intent-describing comment behind. Assertive-claim keywords alone miss this class — the comment doesn't *assert* anything, it *describes* what the code does, so it slips past the original keyword filter.
- **Where:** Step 2 → Sweep 2.4 extended with the second class and a function-body-verification clause.
