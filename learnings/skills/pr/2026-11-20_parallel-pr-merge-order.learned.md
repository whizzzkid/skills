---
skill: wk-pr
date: 2026-11-20
type: correction
severity: medium
verified-against-source: n/a
---

Two "independent" PRs touched the same files, and their merge order and conflict risk were never surfaced.

**What happened:** Two parallel PRs off the default branch both edited shared registries: the import map, the lint
config list, and one view. They were reported as independent and ready. The second one conflicted after the first
merged, and the user had to discover the conflict and ask why the merge order hadn't been raised.

**Root cause:** "Independent" was judged on behaviour, not on file overlap. No step intersects the changed-file sets
of sibling PRs opened in the same session.

**Suggested fix:** When opening two or more PRs from one session, intersect their `git diff --name-only` sets.
Overlap → state the recommended merge order and the expected conflict files in each PR body and in the hand-off.
Offer to update the second PR right after the first merges.
