---
skill: wk-self-review
date: 2026-06-10
type: correction
severity: medium
---

Self-review threads that rationalize a design approach become stale when that approach is later changed in the same PR.

**What happened:** A PR switched from a sequential upload loop to parallel uploads via Promise.all. The existing self-review thread (posted when the sequential approach was chosen) still explained the rationale for serialization. The agent pushed the new commit without auditing the existing self-review threads, leaving a stale comment visible to reviewers that contradicted the current code. The user caught this manually.

**Root cause:** The self-review skill covers "adding new comments for critical changes" on new commits but does not include a step to audit whether existing self-review threads on the same code path have become stale after an approach pivot.

**Suggested fix:** When new commits change the logical approach of a feature (the pivot triggers from wk-workflow's design-pivot rules), add a step to: (1) fetch all unresolved self-review threads on the changed files, (2) check whether any thread's rationale references the old approach, and (3) resolve stale threads and post updated rationale anchored to the new commit. Treat "approach changed, self-review not updated" the same as "stale code comment" — both mislead future readers.
