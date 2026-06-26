---
class: principle
---

**Rule:** In batch mode, re-scan Sources 2/4 (`find ... ! -name '*.learned.md'`)
after each fold-commit-push, not only once at invocation. Treat "inbox drained"
as a terminal check run after the last commit, never a fact set up-front.

**Why:** Concurrent sessions write learnings/retros to the same tree
continuously, so a single up-front scan under-counts and leaves fresh items
unprocessed.

**Where:** Batch Mode → Source 2 (Repo learnings directory).
