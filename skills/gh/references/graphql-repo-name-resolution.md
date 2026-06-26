---
class: principle
---

**Rule:** Resolve the exact repo name via `gh repo view --json owner,name` before
any GraphQL `$owner`/`$repo` call. Never derive the name from a URL slug or an
org-scoped search.

**Why:** GitHub URLs normalize underscores to hyphens in repo paths, but the
GraphQL API requires the stored name verbatim. A slug-derived name on an
underscore-named repo returns `NOT_FOUND` and forces a recovery step.

**Where:** wk-gh Step 3 — the GraphQL surface guidance alongside the REST-id and
`/replies` rules.
