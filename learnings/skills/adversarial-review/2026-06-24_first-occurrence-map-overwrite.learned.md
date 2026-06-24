---
skill: wk-adversarial-review
date: 2026-06-24
type: pattern
severity: medium
---

First-occurrence tracker map silently reports wrong index on 3+ duplicates when the map entry is overwritten unconditionally.

**What happened:** A deduplication/warning loop used `seen[key] = i` on every iteration. When a key appeared at indices 0, 2, and 4, the second warning logged "first seen at 2, again at 4" instead of "first seen at 0, again at 4" — the first occurrence was lost after the first collision.

**Root cause:** The `continue` was missing after logging the duplicate. Without it, `seen[key]` was updated to the duplicate's index, so the "first seen" pointer advanced forward with each occurrence instead of staying anchored at the original entry.

**Suggested fix:** After emitting the warning, `continue` to skip the `seen[key] = i` assignment — the first-occurrence entry stays in the map for all future collisions. Pattern:

```go
if j, dup := seen[key]; dup {
    log.Printf("WARNING: duplicate %q (first at %d, again at %d)", key, j, i)
    continue  // preserve first occurrence; don't overwrite seen[key]
}
seen[key] = i
```

Also note: test suites covering deduplication should include a 3+ occurrence case explicitly — a 2-occurrence test cannot catch this class of bug.
