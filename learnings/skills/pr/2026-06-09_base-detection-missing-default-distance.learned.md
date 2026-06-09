---
skill: wk-pr
date: 2026-06-09
type: gap
severity: medium
---

Base detection loop never measures the actual distance to the default branch.

**What happened:** The detection algorithm initializes `BEST_BASE="$DEFAULT_BRANCH"` with `BEST_DIST=999999`, then iterates only open-PR branches. Any open-PR branch whose measured distance is less than 999999 replaces the default, even when the default is closer. A session where an open PR branch had distance 20 won over main's actual distance of 12.

**Root cause:** The detection loop body runs `git merge-base` and `git rev-list --count` only for open-PR candidates; the default branch's actual merge-base distance is never computed and compared.

**Suggested fix:** Add the default branch to the candidate iteration loop (not just as the starting fallback), so its measured distance is computed and compared on equal footing with every open-PR branch.
