---
skill: wk-buildkite
date: 2026-08-22
type: correction
severity: medium
verified-against-source: yes
---

When explaining a CI failure, distinguish "did my merge trigger this build" from "is my diff the root cause" — and answer both explicitly.

**What happened:** A `main`-only build failed after a merge. The agent investigated the failing step, found it was a separate, non-deterministic issue unrelated to the diff's content, and reported it as "not caused by [the merged PR]" without first stating that merging the PR was in fact what triggered that specific build run. The user pushed back: "it was caused by me merging the change you just created" — technically true at the trigger level, even though the failure mechanism inside the build was unrelated to the diff.

**Root cause:** The investigation conflated two distinct claims — "your merge caused this build to run" (true) and "your diff caused this build's failure" (false) — into one blended verdict, leading with the second and omitting the first.

**Suggested fix:** When reporting a post-merge CI failure, always state both facts separately and explicitly: (1) whether this build run was triggered by the user's merge/push, and (2) whether the failure inside that build is attributable to their diff's content. Never collapse them into a single "related/unrelated" verdict.
