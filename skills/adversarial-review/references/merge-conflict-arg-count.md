---
class: principle
---

**Rule:** When a merge/rebase conflict lands at a function call site, compare
both sides' argument counts against the current base-branch signature. The
base signature is authoritative for required params; a side missing a required
arg is stale (the branch was cut before the signature changed), not a
"which caller wins" choice. Flag the short call as a correctness defect.

**Why:** Both sides may compile independently, so the conflict reads as a style
preference. It is not — the stale side drops a required argument and is wrong
regardless of which branch owns the call site.

**Where:** Step 2 sweep catalog, row 2.44.
