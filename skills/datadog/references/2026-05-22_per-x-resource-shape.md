---
name: per-x-resource-shape
description: Resolve "per X" requests to dashboard-with-template-vars or per-instance notebook before building.
class: principle
---

- **Rule:** When the user says "create X per Y", clarify whether
  they want one reusable artifact filtered by Y (dashboard with
  template variables) or a new artifact per Y instance (notebook
  per incident). Ask before building if the intent isn't explicit.
- **Why:** "Per X" phrasing maps to two opposite Datadog patterns.
  Defaulting to per-instance creation when the user wanted a
  filterable dashboard generates thousands of dead artifacts and
  misses the canonical pattern.
- **Where:** New Step 1.5 "Resolve resource-type intent before
  any write" between Step 1 and Step 2.
