---
class: principle
---

**Rule:** When deriving a project-transcript directory slug from `$PWD`, normalize
both `/` and `_` to `-` (`sed 's|[/_]|-|g'`). On a slug-derived miss, list the
transcript root and fuzzy-match by longest common substring before reporting zero.

**Why:** The transcript dir naming collapses underscores to hyphens as well as
slashes. A slug that only replaces `/` silently matches nothing for any repo whose
name contains an underscore — `find` returns empty and the scan reports zero
interruptions without warning.

**Where:** wk-learn Scan Mode Step S1.
