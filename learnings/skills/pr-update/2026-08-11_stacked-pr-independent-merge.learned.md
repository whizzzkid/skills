---
skill: wk-pr-update
date: 2026-08-11
type: gap
severity: high
verified-against-source: yes
---

Stacked PR with independently-merged parent branches produces massive
add/add conflicts when merged — detect and rebase `--onto` instead.

**What happened:** A stacked PR (part-4/4) locally contained commits from
parts 1-3 as its own history (local merges of parent branches into child).
Meanwhile, parts 1-3 merged into main independently via separate reviewed
PRs with a different commit structure. `git merge origin/main` produced
~30 add/add conflicts because the same files were introduced by both
histories with slightly different content.

**Root cause:** The merge strategy (Stage 2) does not detect the
"independently-merged parents" pattern — where a branch's early commits
duplicate work that has already landed on the base via separate PRs. The
merge-aware `$AHEAD` recomputation only looks for base-branch merge
commits, not for content overlap between the branch's early history and
the base's merged PRs. This pattern is common in stacked PR workflows
where each child carries the parent's commits locally.

**Suggested fix:** Before choosing a merge strategy, compare the branch's
pre-fork commits against the base's merged PR history. If the branch
contains commits whose authored content matches (by diff or message
pattern) commits already on base, classify as "independently-merged
parents" and: (1) identify the boundary commit where the branch's own
new work begins, (2) use `git rebase --onto $BASE_REF <boundary-commit>`
or cherry-pick only the branch's own commits, skipping the duplicated
parent history entirely. This avoids the 30+ add/add conflicts and
produces a clean linear history.
