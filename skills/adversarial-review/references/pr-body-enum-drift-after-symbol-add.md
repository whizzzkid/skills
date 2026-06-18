---
class: principle
---

**Rule:** For each enum-like list in the PR body (reason symbols, tags, flags, error codes), grep post-diff code for all current values and compare against the body list; any code value missing from the body is drift.

**Why:** Adding a new enum value (or splitting a catch-all into granular symbols) leaves the PR body's enumeration stale. Sweep 2.8 already catches this reliably (already-covered); 2.10 sharpened with the explicit enumerate-and-compare mechanism.

**Where:** Sweeps 2.8 and 2.10.
