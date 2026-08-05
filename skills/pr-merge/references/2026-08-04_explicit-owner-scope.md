---
class: principle
---

# Keep explicit repository identity through the merge flow

**Rule:** Resolve `{owner}/{repo}` from the target PR and pass it through every
scoped read, mutation, merge, branch-deletion, and verification command.

**Why:** Ambient organization or remote defaults can address another repository
when the user explicitly targets a PR outside that scope.

**Where:** PR resolution, merge gates, child retargeting, ticket handling, and
remote-branch cleanup.
