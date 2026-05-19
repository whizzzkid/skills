---
class: principle
date: 2026-05-19
---

- **Rule:** When a named constant is removed in the diff, grep the
  post-rebase diff for its literal value; flag as `suggestion` when it
  appears at 2+ non-comment sites.
- **Why:** Removing a constant as "unused" often masks inlining the
  literal at multiple call-sites, re-introducing the duplication the
  constant existed to prevent.
- **Where:** Step 2 sweep 2.18.
