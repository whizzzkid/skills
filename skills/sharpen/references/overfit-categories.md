---
class: principle
---

**Rule** — Grep every proposed edit (and every reference file) against all nine overfit
categories before presenting the diff:

1. Reviewer / bot logins
2. Organization prefixes
3. Employer / internal project names
4. Specific ticket IDs
5. Specific repo / file / package names
6. Line numbers / SHAs / PR numbers
7. Specific tool versions
8. Concrete person names
9. Hardcoded branch names

**Why** — A rule carrying any of these reads as authoritative but only ever matches the one
incident that produced it, so the next run either mis-applies it or skips it. The categories are
the enumerable form of the skill's core rule (extract principles, not examples); keeping the list
out of line keeps the scan step short without dropping a category.

**Where** — Relocated from the inline list in the Mechanical overfit scan, which now points here.
The scan's non-enumerable rules (replacement-longest-first, ticket-shape rejection, run-the-hooks,
staged-path hand-roll) stay inline because they are procedure, not a checklist.
