---
class: principle
---

# Probe every canonical field and recursive source root

**Rule:** For a public projection, enumerate every consumed field and source
root. Mutate field semantics and URL components, seed below recursive roots,
and sort filesystem inputs before checking aggregate failures.

**Why:** Shape checks can pass while public values drift or recursive scans miss
nested invalid artifacts.

**Where:** Mechanical sweep 2.89 for spec and configuration validators.
