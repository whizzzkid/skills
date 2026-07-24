---
class: principle
---

# Render verification must assert containment, not presence

**Rule:** A render assertion that counts containers and checks them non-empty is not
sufficient. For every nested marker class, assert its scoped count equals its global
count — `querySelectorAll('PARENT CHILD').length === querySelectorAll('CHILD').length`
— so content that escaped its container fails the gate.

**Why:** Nested content ejected out of its parent is still *present* on the page and
the parent is still *non-empty*, so a presence/count assertion returns `true` on a
visibly broken layout. The break then surfaces only when a human looks at a
screenshot — an eyeball check is not systematic and will miss it on other runs.

**Where:** Stage 5 pre-announce render gate (assertion extended with the containment
clause); the generic form lives in the browser-verification step of the page-authoring
skill. Generalizes to any DOM/structure verification, not just column layouts.
